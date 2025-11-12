import 'package:cloud_firestore/cloud_firestore.dart';
import 'meal_item.dart';

class Meal {
  final String id; // docId (pode ser '' quando novo)
  final String userId; // uid do FirebaseAuth
  final String name; // "Almoço", "Café da manhã", etc.
  final DateTime date; // data/hora da refeição
  final List<MealItem> items;

  const Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.items,
  });

  // Totais calculados (não dependem do que vem do Firestore)
  double get totalKcal => items.fold<double>(0.0, (a, b) => a + b.kcal);
  double get totalProtein => items.fold<double>(0.0, (a, b) => a + b.protein);
  double get totalCarbs => items.fold<double>(0.0, (a, b) => a + b.carbs);
  double get totalFat => items.fold<double>(0.0, (a, b) => a + b.fat);

  /// Payload salvo no Firestore
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'date': Timestamp.fromDate(date),
        'items': items.map((e) => e.toJson()).toList(),
        'totals': {
          'kcal': totalKcal,
          'protein': totalProtein,
          'carbs': totalCarbs,
          'fat': totalFat,
        },
      };

  /// Leitura robusta de snapshot (Map já extraído)
  factory Meal.fromSnapshot(String id, Map<String, dynamic> m) {
    return Meal(
      id: id,
      userId: (m['userId'] ?? '') as String,
      name: (m['name'] ?? '') as String,
      date: _parseDate(m['date']),
      items: ((m['items'] as List?) ?? const [])
          .map((e) => MealItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  /// Atalho direto de DocumentSnapshot (tipado)
  factory Meal.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Meal.fromSnapshot(doc.id, data);
  }

  Meal copyWith({
    String? name,
    DateTime? date,
    List<MealItem>? items,
  }) =>
      Meal(
        id: id,
        userId: userId,
        name: name ?? this.name,
        date: date ?? this.date,
        items: items ?? this.items,
      );

  // -------- Helpers privados --------

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      // Tenta ISO-8601
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    if (value is int) {
      // milissegundos desde epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    // fallback: agora
    return DateTime.now();
  }
}
