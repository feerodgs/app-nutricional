import 'package:nutri_plan/src/models/meal_item.dart';

class MealTemplate {
  final String name;
  final List<MealItem> items;
  final List<String> tags;

  MealTemplate({
    required this.name,
    required this.items,
    required this.tags,
  });

  factory MealTemplate.fromJson(Map<String, dynamic> json) {
    return MealTemplate(
      name: json['name'],
      items: (json['items'] as List).map((e) => MealItem.fromJson(e)).toList(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
