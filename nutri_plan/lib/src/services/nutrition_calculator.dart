class NutritionResult {
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  NutritionResult({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class NutritionCalculator {
  final int age;
  final String gender;
  final double weight;
  final double height;
  final String goal;
  final String activityLevel;

  NutritionCalculator({
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.goal,
    required this.activityLevel,
  });

  double _tmb() {
    if (gender == "m") {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  double _tdee(double tmb) {
    const factors = {
      "sedentary": 1.2,
      "light": 1.375,
      "moderate": 1.55,
      "intense": 1.725,
      "athlete": 1.9,
    };
    return tmb * (factors[activityLevel] ?? 1.55);
  }

  double _adjustGoal(double tdee) {
    if (goal == "cut") return tdee * 0.80;
    if (goal == "bulk") return tdee * 1.15;
    return tdee;
  }

  NutritionResult calculate() {
    final tmb = _tmb();
    final tdee = _tdee(tmb);
    final kcal = _adjustGoal(tdee);

    final protein = (kcal * 0.30) / 4;
    final carbs = (kcal * 0.40) / 4;
    final fat = (kcal * 0.30) / 9;

    return NutritionResult(
      kcal: kcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }
}
