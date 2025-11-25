import '../models/meal.dart';
import '../models/meal_item.dart';
import '../data/meal_templates_repository.dart';

class MealsGenerator {
  static Future<List<Meal>> generate(String uid, String goal) async {
    final templates = await MealTemplatesRepository.load();

    final key = _mapGoal(goal);
    final group = templates[key];
    if (group == null || group.isEmpty) return [];

    final now = DateTime.now();

    return group.map((template) {
      return Meal(
        id: '',
        userId: uid,
        name: template.name,
        date: now,
        done: false,
        items: template.items.map((e) {
          return MealItem(
            food: e.food,
            quantity: e.quantity,
            unit: e.unit,
            kcal: e.kcal,
            protein: e.protein,
            carbs: e.carbs,
            fat: e.fat,
          );
        }).toList(),
      );
    }).toList();
  }

  static String _mapGoal(String goal) {
    switch (goal) {
      case 'emagrecer':
        return 'cutting';
      case 'ganhar':
        return 'bulking';
      case 'manter':
        return 'maintenance';
      default:
        return 'maintenance';
    }
  }
}
