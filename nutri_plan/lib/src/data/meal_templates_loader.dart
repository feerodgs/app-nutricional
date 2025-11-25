import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/meal_template.dart';

class MealTemplatesLoader {
  static Future<List<MealTemplate>> loadAll() async {
    final raw = await rootBundle.loadString('assets/meals.json');
    final json = jsonDecode(raw);

    final List list = json['meals'] ?? [];

    return list.map((e) => MealTemplate.fromJson(e)).toList();
  }
}
