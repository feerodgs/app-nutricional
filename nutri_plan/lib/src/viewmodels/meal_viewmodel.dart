import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/meal_repository.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';

class MealViewModel extends ChangeNotifier {
  bool saving = false;
  String? error;

  // estado do formulário
  String name = 'Refeição';
  DateTime date = DateTime.now();
  final List<MealItem> items = [];

  void setName(String v) {
    name = v;
    notifyListeners();
  }

  void setDate(DateTime v) {
    date = v;
    notifyListeners();
  }

  void addItem(MealItem item) {
    items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  Future<String?> save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      error = 'Usuário não autenticado';
      notifyListeners();
      return null;
    }
    if (items.isEmpty) {
      error = 'Adicione pelo menos um item';
      notifyListeners();
      return null;
    }

    saving = true;
    error = null;
    notifyListeners();
    try {
      final meal = Meal(
          id: '',
          userId: user.uid,
          name: name,
          date: date,
          items: List.of(items));
      final id = await MealRepository.create(meal);
      saving = false;
      notifyListeners();
      return id;
    } catch (e) {
      saving = false;
      error = 'Erro ao salvar refeição';
      notifyListeners();
      return null;
    }
  }
}
