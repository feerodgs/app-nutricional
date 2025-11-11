class MealItem {
  final String food; // ex: "Frango grelhado"
  final double quantity; // ex: 150
  final String unit; // ex: "g"
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  const MealItem({
    required this.food,
    required this.quantity,
    required this.unit,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
        'food': food,
        'quantity': quantity,
        'unit': unit,
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory MealItem.fromJson(Map<String, dynamic> m) => MealItem(
        food: m['food'],
        quantity: (m['quantity'] as num).toDouble(),
        unit: m['unit'],
        kcal: (m['kcal'] as num).toDouble(),
        protein: (m['protein'] as num).toDouble(),
        carbs: (m['carbs'] as num).toDouble(),
        fat: (m['fat'] as num).toDouble(),
      );
}
