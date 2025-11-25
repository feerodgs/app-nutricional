import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../data/meal_repository.dart';
import '../services/daily_meal_service.dart';

class DailyMealViewModel extends ChangeNotifier {
  bool loading = false;
  List<Meal> meals = [];

  Future<void> load(String uid) async {
    loading = true;
    notifyListeners();

    await DailyMealService.generateIfEmpty(uid);

    MealRepository.watchAll(uid, day: DateTime.now()).listen((list) {
      meals = list;
      notifyListeners();
    });

    loading = false;
    notifyListeners();
  }
}
