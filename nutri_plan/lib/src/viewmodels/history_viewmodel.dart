import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/meal_repository.dart';
import '../models/meal.dart';

enum HistoryQuickRange { hoje, seteDias, trintaDias, custom }

class HistoryViewModel extends ChangeNotifier {
  HistoryQuickRange range = HistoryQuickRange.seteDias;
  DateTime? customStart;
  DateTime? customEnd;
  String query = '';

  List<Meal> meals = [];
  bool loading = false;
  String? error;

  StreamSubscription<List<Meal>>? _sub; // <- controla o stream

  void setRange(HistoryQuickRange r) {
    range = r;
  }

  void setQuery(String v) {
    query = v;
  }

  void setCustom(DateTime start, DateTime end) {
    customStart = start;
    customEnd = end;
    range = HistoryQuickRange.custom;
  }

  ({DateTime start, DateTime end}) _calcWindow() {
    final now = DateTime.now();
    switch (range) {
      case HistoryQuickRange.hoje:
        final s = DateTime(now.year, now.month, now.day);
        return (start: s, end: s.add(const Duration(days: 1)));
      case HistoryQuickRange.seteDias:
        final s = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        final e =
            DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        return (start: s, end: e);
      case HistoryQuickRange.trintaDias:
        final s = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 29));
        final e =
            DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        return (start: s, end: e);
      case HistoryQuickRange.custom:
        final s = customStart ?? DateTime(now.year, now.month, now.day);
        final e = (customEnd ?? now).add(const Duration(days: 1));
        return (
          start: DateTime(s.year, s.month, s.day),
          end: DateTime(e.year, e.month, e.day)
        );
    }
  }

  Future<void> load() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      error = 'Sem usuário';
      notifyListeners();
      return;
    }

    // cancela o listener anterior antes de abrir outro
    await _sub?.cancel();
    loading = true;
    error = null;
    notifyListeners();

    final w = _calcWindow();
    _sub =
        MealRepository.watchRangeHistory(u.uid, w.start, w.end).listen((list) {
      final q = query.toLowerCase();
      meals = q.isEmpty
          ? list
          : list.where((m) => m.name.toLowerCase().contains(q)).toList();
      loading = false;
      notifyListeners();
    }, onError: (e) {
      error = 'Erro ao carregar';
      loading = false;
      notifyListeners();
    });
  }

  double get totKcal => meals.fold(0, (a, m) => a + m.totalKcal);
  double get totProt => meals.fold(0, (a, m) => a + m.totalProtein);
  double get totCarb => meals.fold(0, (a, m) => a + m.totalCarbs);
  double get totFat => meals.fold(0, (a, m) => a + m.totalFat);

  Map<DateTime, double> kcalByDay() {
    final map = <DateTime, double>{};
    for (final m in meals) {
      final d = DateTime(m.date.year, m.date.month, m.date.day);
      map[d] = (map[d] ?? 0) + m.totalKcal;
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
