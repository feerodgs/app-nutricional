import 'package:flutter/material.dart';

import '../data/meal_repository.dart';
import '../data/settings_repository.dart';
import '../data/meals_generator.dart';
import '../models/user_goals.dart';

class DailyMealService {
  /// Gera refeições apenas se o dia estiver vazio
  static Future<void> generateIfEmpty(String uid) async {
    final todayMeals =
        await MealRepository.watchAll(uid, day: DateTime.now()).first;

    if (todayMeals.isNotEmpty) return;

    final goals = await SettingsRepository.getGoals(uid);

    // AGORA CORRETO — envia UserGoals inteiro
    final meals = await MealsGenerator.generate(uid, goals);

    await MealRepository.createMany(uid, meals);
  }

  /// Gera refeições novas (usado no botão)
  static Future<void> generateFresh(String uid) async {
    // Remove refeições do dia
    await MealRepository.deleteDay(uid, DateTime.now());

    // Lê metas
    final goals = await SettingsRepository.getGoals(uid);

    // AGORA CORRETO — envia UserGoals inteiro
    final meals = await MealsGenerator.generate(uid, goals);

    // Grava no Firestore
    await MealRepository.createMany(uid, meals);
  }

  static Future<void> generateWithParams({
    required String uid,
    required int days,
    required int mealsPerDay,
    required List<TimeOfDay> times,
    required UserGoals goals,
  }) async {
    final now = DateTime.now();

    for (int d = 0; d < days; d++) {
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: d));

      await MealRepository.deleteDay(uid, day);

      final meals = await MealsGenerator.generateWithRules(
        uid: uid,
        goals: goals,
        mealsPerDay: mealsPerDay,
        times: times,
        day: day,
      );

      await MealRepository.createMany(uid, meals);
    }
  }
}
