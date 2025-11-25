import 'package:flutter/foundation.dart';
import '../../models/user_goals.dart';

class OnboardingViewModel extends ChangeNotifier {
  int? age;
  String? gender;
  double? weight;
  double? height;
  String? activity;
  String? goal;
  List<String> restrictions = [];

  void setAge(int v) {
    age = v;
    notifyListeners();
  }

  void setGender(String v) {
    gender = v;
    notifyListeners();
  }

  void setWeight(double v) {
    weight = v;
    notifyListeners();
  }

  void setHeight(double v) {
    height = v;
    notifyListeners();
  }

  void setActivity(String v) {
    activity = v;
    notifyListeners();
  }

  void setGoal(String v) {
    goal = v;
    notifyListeners();
  }

  void toggleRestriction(String r) {
    if (restrictions.contains(r)) {
      restrictions.remove(r);
    } else {
      restrictions.add(r);
    }
    notifyListeners();
  }

  bool get isComplete =>
      age != null &&
      gender != null &&
      weight != null &&
      height != null &&
      activity != null &&
      goal != null;

  double get tmb {
    if (age == null || weight == null || height == null || gender == null) {
      return 0;
    }

    final w = weight!;
    final h = height!;
    final a = age!;
    final isMale = gender == "masculino";

    return isMale
        ? (10 * w) + (6.25 * h) - (5 * a) + 5
        : (10 * w) + (6.25 * h) - (5 * a) - 161;
  }

  double get fatorAtividade {
    switch (activity) {
      case "sedentario":
        return 1.2;
      case "moderado":
        return 1.55;
      case "intenso":
        return 1.75;
      default:
        return 1.2;
    }
  }

  double get tdee => tmb * fatorAtividade;

  /// Ajuste correto usando termos do onboarding
  double get caloriasObjetivo {
    if (goal == "emagrecer") return tdee - 300;
    if (goal == "ganhar") return tdee + 300;
    return tdee;
  }

  double get protein {
    if (weight == null) return 0;
    return 2.0 * weight!;
  }

  double get fat {
    return caloriasObjetivo * 0.25 / 9;
  }

  double get carbs {
    final kcalsProtein = protein * 4;
    final kcalsFat = fat * 9;
    final kcalsCarbs = caloriasObjetivo - kcalsProtein - kcalsFat;
    return kcalsCarbs / 4;
  }

  /// Agora exportamos o objetivo final para o JSON
  String get goalType {
    if (goal == "emagrecer") return "cutting";
    if (goal == "ganhar") return "bulking";
    return "maintenance";
  }

  UserGoals toUserGoals() {
    return UserGoals(
      kcal: caloriasObjetivo,
      protein: protein,
      carbs: carbs,
      fat: fat,
      goalType: goal == "cutting"
          ? "cutting"
          : goal == "bulking"
              ? "bulking"
              : "maintenance",
    );
  }
}
