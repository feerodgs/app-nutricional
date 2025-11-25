import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../models/user_goals.dart';

class MealsGenerator {
  /// Carrega o banco de refeições
  static Future<Map<String, dynamic>> _loadDB() async {
    final raw = await rootBundle.loadString("assets/meals.json");
    return jsonDecode(raw);
  }

  /// Método antigo (mantido para compatibilidade)
  static Future<List<Meal>> generate(String uid, UserGoals goals) async {
    return generateWithRules(
      uid: uid,
      goals: goals,
      mealsPerDay: 4,
      times: const [],
      day: DateTime.now(),
    );
  }

  /// 🔥 NOVO MÉTODO — gera refeições organizadas por refeição (café, almoço…)
  static Future<List<Meal>> generateWithRules({
    required String uid,
    required UserGoals goals,
    required int mealsPerDay,
    required List<dynamic> times,
    required DateTime day,
  }) async {
    final db = await _loadDB();
    final mealsByType = db[goals.goalType]?["meals"] as List? ?? [];

    if (mealsByType.isEmpty) return [];

    // TAGS por tipo de refeição
    const mealTags = {
      "cafe": ["cafe", "breakfast", "morning"],
      "almoco": ["almoco", "lunch"],
      "lanche": ["snack", "lanche"],
      "jantar": ["jantar", "dinner"]
    };

    // Tipos fixos de refeição
    final slots = ["cafe", "almoco", "lanche", "jantar"];

    // Se o usuário pedir mais que 4 refeições, duplicamos lanches
    final selectedSlots = mealsPerDay <= 4
        ? slots.take(mealsPerDay).toList()
        : [...slots, ...List.filled(mealsPerDay - 4, "lanche")];

    final List<Meal> finalList = [];

    for (var i = 0; i < selectedSlots.length; i++) {
      final slot = selectedSlots[i];

      // Seleciona horário informado (se existir)
      final time =
          (i < times.length) ? times[i] : const TimeOfDay(hour: 12, minute: 0);

      final mealDate = DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      );

      // Filtra refeições pela tag
      final matching = mealsByType.where((m) {
        final tags = List<String>.from(m["tags"] ?? []);
        return tags.any((t) => mealTags[slot]!.contains(t));
      }).toList();

      if (matching.isEmpty) continue;

      matching.shuffle();
      final chosen = matching.first;

      // Converte items → MealItem
      final items = (chosen["items"] as List).map((i) {
        return MealItem(
          food: i["food"],
          quantity: (i["quantity"] * 1.0),
          unit: i["unit"],
          kcal: (i["kcal"] * 1.0),
          protein: (i["protein"] * 1.0),
          carbs: (i["carbs"] * 1.0),
          fat: (i["fat"] * 1.0),
        );
      }).toList();

      finalList.add(
        Meal(
          id: "",
          userId: uid,
          name: _formatMealName(slot),
          date: mealDate,
          done: false,
          items: items,
        ),
      );
    }

    return finalList;
  }

  /// Nome exibido da refeição
  static String _formatMealName(String slot) {
    switch (slot) {
      case "cafe":
        return "Café da manhã";
      case "almoco":
        return "Almoço";
      case "lanche":
        return "Lanche";
      case "jantar":
        return "Jantar";
      default:
        return "Refeição";
    }
  }
}
