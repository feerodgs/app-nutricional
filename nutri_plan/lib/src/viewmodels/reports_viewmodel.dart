import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/meal_repository.dart';
import '../models/meal.dart';

enum QuickRange { hoje, seteDias, trintaDias, custom }

class ReportsViewModel extends ChangeNotifier {
  QuickRange range = QuickRange.seteDias;
  DateTime? customStart;
  DateTime? customEnd;
  String query = ''; // filtro por nome da refeição

  // dados
  List<Meal> meals = [];
  bool loading = false;
  String? error;

  void setRange(QuickRange r) {
    range = r;
    notifyListeners();
  }

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void setCustom(DateTime start, DateTime end) {
    customStart = start;
    customEnd = end;
    range = QuickRange.custom;
    notifyListeners();
  }

  ({DateTime start, DateTime end}) _calcWindow() {
    final now = DateTime.now();
    switch (range) {
      case QuickRange.hoje:
        final s = DateTime(now.year, now.month, now.day);
        return (start: s, end: s.add(const Duration(days: 1)));
      case QuickRange.seteDias:
        final s = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        final e =
            DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        return (start: s, end: e);
      case QuickRange.trintaDias:
        final s = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 29));
        final e =
            DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        return (start: s, end: e);
      case QuickRange.custom:
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

    loading = true;
    error = null;
    notifyListeners();
    try {
      final w = _calcWindow();
      // 1x subscribe immediate snapshot (pequeno, simples):
      MealRepository.watchRange(u.uid, w.start, w.end).listen((list) {
        meals = list
            .where((m) =>
                query.isEmpty ||
                m.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        notifyListeners();
      });
    } catch (e) {
      error = 'Erro ao carregar';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // agregados
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
}
