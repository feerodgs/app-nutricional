import 'package:cloud_firestore/cloud_firestore.dart';
import 'meal_item.dart';

class Meal {
  final String id;
  final String userId;
  final String name;
  final DateTime date;
  final List<MealItem> items;
  final bool done;

  const Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.items,
    required this.done,
  });

  double get totalKcal => items.fold(0.0, (a, b) => a + b.kcal);
  double get totalProtein => items.fold(0.0, (a, b) => a + b.protein);
  double get totalCarbs => items.fold(0.0, (a, b) => a + b.carbs);
  double get totalFat => items.fold(0.0, (a, b) => a + b.fat);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'date': Timestamp.fromDate(date),
        'items': items.map((e) => e.toJson()).toList(),
        'done': done,
        'totals': {
          'kcal': totalKcal,
          'protein': totalProtein,
          'carbs': totalCarbs,
          'fat': totalFat,
        },
      };

  factory Meal.fromSnapshot(String id, Map<String, dynamic> m) {
    return Meal(
      id: id,
      userId: (m['userId'] ?? '') as String,
      name: (m['name'] ?? '') as String,
      date: _parseDate(m['date']),
      items: ((m['items'] as List?) ?? const [])
          .map((e) => MealItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      done: m['done'] == true,
    );
  }

  factory Meal.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Meal.fromSnapshot(doc.id, data);
  }

  Meal copyWith({
    String? name,
    DateTime? date,
    List<MealItem>? items,
    bool? done,
  }) {
    return Meal(
      id: id,
      userId: userId,
      name: name ?? this.name,
      date: date ?? this.date,
      items: items ?? this.items,
      done: done ?? this.done,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }
}
