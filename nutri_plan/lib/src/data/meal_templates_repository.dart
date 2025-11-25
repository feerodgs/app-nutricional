import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/meal_item.dart';

class MealTemplate {
  final String name;
  final List<MealItem> items;
  final List<String> tags;

  MealTemplate({
    required this.name,
    required this.items,
    required this.tags,
  });

  factory MealTemplate.fromJson(Map<String, dynamic> j) {
    return MealTemplate(
      name: j['name'],
      tags: List<String>.from(j['tags'] ?? []),
      items: (j['items'] as List)
          .map((e) => MealItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class MealTemplatesRepository {
  static Map<String, List<MealTemplate>>? _cache;

  static Future<Map<String, List<MealTemplate>>> load() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/meals.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;

    _cache = json.map((key, value) {
      final list = (value as List)
          .map((e) => MealTemplate.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return MapEntry(key, list);
    });

    return _cache!;
  }
}
