import 'package:cloud_firestore/cloud_firestore.dart';
import 'meal_item.dart';

class Meal {
  final String id; // doc id (uuid) — pode ser vazio para novo
  final String userId; // uid do FirebaseAuth
  final String name; // "Almoço", "Café da manhã", etc.
  final DateTime date; // dia/hora da refeição
  final List<MealItem> items; // itens da refeição

  const Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.items,
  });

  double get totalKcal => items.fold(0, (a, b) => a + b.kcal);
  double get totalProtein => items.fold(0, (a, b) => a + b.protein);
  double get totalCarbs => items.fold(0, (a, b) => a + b.carbs);
  double get totalFat => items.fold(0, (a, b) => a + b.fat);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'date': Timestamp.fromDate(date),
        'items': items.map((e) => e.toJson()).toList(),
        'totals': {
          'kcal': totalKcal,
          'protein': totalProtein,
          'carbs': totalCarbs,
          'fat': totalFat
        },
      };

  factory Meal.fromSnapshot(String id, Map<String, dynamic> m) => Meal(
        id: id,
        userId: m['userId'],
        name: m['name'],
        date: (m['date'] as Timestamp).toDate(),
        items: (m['items'] as List)
            .map((e) => MealItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Meal copyWith({String? name, DateTime? date, List<MealItem>? items}) => Meal(
        id: id,
        userId: userId,
        name: name ?? this.name,
        date: date ?? this.date,
        items: items ?? this.items,
      );
}
