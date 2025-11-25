import '../data/meal_repository.dart';
import '../data/settings_repository.dart';
import '../models/user_goals.dart';
import '../data/meals_generator.dart';

class DailyMealService {
  static Future<void> generateIfEmpty(String uid) async {
    final todayMeals =
        await MealRepository.watchAll(uid, day: DateTime.now()).first;

    if (todayMeals.isNotEmpty) return;

    final goals = await SettingsRepository.getGoals(uid);

    final meals = await MealsGenerator.generate(uid, goals.goalType);

    await MealRepository.createMany(uid, meals);
  }
}
