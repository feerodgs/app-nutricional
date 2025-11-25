import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';
import '../models/user_goals.dart';

class MealsGenerator {
  static Future<List<Meal>> generate(String uid, UserGoals goals) async {
    final raw = await rootBundle.loadString("assets/meals.json");
    final data = jsonDecode(raw);

    final list = (data[goals.goalType]["meals"] as List);

    List<Map<String, dynamic>> all = List<Map<String, dynamic>>.from(list);

    Map<String, List<Map<String, dynamic>>> byTag = {
      "cafe": [],
      "almoco": [],
      "lanche": [],
      "jantar": [],
    };

    for (var meal in all) {
      final tags = List<String>.from(meal["tags"] ?? []);
      if (tags.contains("cafe")) byTag["cafe"]!.add(meal);
      if (tags.contains("almoco")) byTag["almoco"]!.add(meal);
      if (tags.contains("snack") || tags.contains("lanche"))
        byTag["lanche"]!.add(meal);
      if (tags.contains("jantar")) byTag["jantar"]!.add(meal);
    }

    Map<String, Map<String, dynamic>> selected = {
      "cafe": _pickOne(byTag["cafe"], all),
      "almoco": _pickOne(byTag["almoco"], all),
      "lanche": _pickOne(byTag["lanche"], all),
      "jantar": _pickOne(byTag["jantar"], all),
    };

    List<Meal> out = [];

    out.add(_buildMeal(uid, "Café da manhã", selected["cafe"]!));
    out.add(_buildMeal(uid, "Almoço", selected["almoco"]!));
    out.add(_buildMeal(uid, "Lanche", selected["lanche"]!));
    out.add(_buildMeal(uid, "Jantar", selected["jantar"]!));

    return out;
  }

  static Map<String, dynamic> _pickOne(List? list, List full) {
    if (list != null && list.isNotEmpty) return list.first;
    return full.first;
  }

  static Meal _buildMeal(String uid, String title, Map<String, dynamic> src) {
    return Meal(
      id: "",
      userId: uid,
      name: title,
      date: DateTime.now(),
      done: false,
      items: (src["items"] as List).map((i) {
        return MealItem(
          food: i["food"],
          quantity: (i["quantity"] as num).toDouble(),
          unit: i["unit"],
          kcal: (i["kcal"] as num).toDouble(),
          protein: (i["protein"] as num).toDouble(),
          carbs: (i["carbs"] as num).toDouble(),
          fat: (i["fat"] as num).toDouble(),
        );
      }).toList(),
    );
  }
}
