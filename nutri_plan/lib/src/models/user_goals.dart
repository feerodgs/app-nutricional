class UserGoals {
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  const UserGoals(
      {required this.kcal,
      required this.protein,
      required this.carbs,
      required this.fat});

  static const UserGoals defaults =
      UserGoals(kcal: 2200, protein: 150, carbs: 250, fat: 70);

  Map<String, dynamic> toJson() => {
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory UserGoals.fromJson(Map<String, dynamic>? m) {
    if (m == null) return defaults;
    double _d(String k) => (m[k] is num) ? (m[k] as num).toDouble() : 0.0;
    return UserGoals(
        kcal: _d('kcal'),
        protein: _d('protein'),
        carbs: _d('carbs'),
        fat: _d('fat'));
  }
}
