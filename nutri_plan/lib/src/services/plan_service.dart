import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../models/user_goals.dart';
import '../data/meal_repository.dart';
import 'plan_generator.dart';

class PlanService {
  static final PlanService _i = PlanService._();
  factory PlanService() => _i;
  PlanService._();

  late PlanGenerator _gen;
  bool _ready = false;

  Future<void> _initFromAssets(String foodsAssetPath, {int? seed}) async {
    if (_ready) return;
    final raw = await rootBundle.loadString(foodsAssetPath);
    final foods = (json.decode(raw) as List)
        .map((e) => Food.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    _gen = PlanGenerator.fromFoods(
      foods: foods,
      rng: seed != null ? Random(seed) : Random(),
    );
    _gen.buildIndexes();
    _ready = true;
  }

  /// Gera refeições (Meal/MealItem) e persiste no Firestore.
  /// Retorna a quantidade de refeições criadas.
  Future<int> generateMealsAndPersist({
    required String uid,
    required UserGoals goals,
    required int days,
    required int mealsPerDay,
    List<String> dislikes = const [],
    List<String> allergies = const [],
    String foodsAssetPath = 'assets/foods.json',
  }) async {
    await _initFromAssets(foodsAssetPath);

    final planDays = await _gen.generate(
      kcalTarget: goals.kcal,
      proteinTarget: goals.protein,
      carbsTarget: goals.carbs,
      fatTarget: goals.fat,
      days: days,
      mealsPerDay: mealsPerDay,
      dislikes: dislikes,
      allergies: allergies,
    );

    // Converte PlanDay -> List<Meal>
    final meals = <Meal>[];
    final today = DateTime.now();
    for (final d in planDays) {
      final baseDate = DateTime(today.year, today.month, today.day)
          .add(Duration(days: d.index - 1));
      for (var i = 0; i < d.meals.length; i++) {
        final m = d.meals[i];

        // hora “plausível” por índice
        final date = DateTime(baseDate.year, baseDate.month, baseDate.day,
            [8, 12, 16, 20][i % 4], 0);

        meals.add(
          Meal(
            id: '',
            userId: uid,
            name: m.name,
            date: date,
            items: m.items
                .map((it) => MealItem(
                      food: it.food,
                      quantity: it.quantity,
                      unit: it.unit,
                      kcal: it.kcal,
                      protein: it.protein,
                      carbs: it.carbs,
                      fat: it.fat,
                    ))
                .toList(),
            done: false,
          ),
        );
      }
    }

    await MealRepository.batchInsert(uid, meals);
    return meals.length;
  }
}
