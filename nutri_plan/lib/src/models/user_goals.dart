class UserGoals {
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final String goalType;

  const UserGoals({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.goalType,
  });

  static UserGoals get defaults => const UserGoals(
        kcal: 2000,
        protein: 100,
        carbs: 200,
        fat: 60,
        goalType: 'maintenance',
      );

  factory UserGoals.fromJson(Map<String, dynamic>? j) {
    j ??= {};

    return UserGoals(
      kcal: (j['kcal'] ?? 2000).toDouble(),
      protein: (j['protein'] ?? 100).toDouble(),
      carbs: (j['carbs'] ?? 200).toDouble(),
      fat: (j['fat'] ?? 60).toDouble(),
      goalType: j['goalType'] ?? 'maintenance',
    );
  }

  Map<String, dynamic> toJson() => {
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'goalType': goalType,
      };
}
