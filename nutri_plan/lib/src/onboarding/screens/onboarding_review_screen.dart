import 'package:flutter/material.dart';
import 'package:nutri_plan/src/views/plan/daily_meal_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../viewmodels/onboarding_viewmodel.dart';
import '../../data/settings_repository.dart';
import '../../data/user_repository.dart';
import '../../models/user_goals.dart';
import '../../views/home/home_view.dart';

class OnboardingReviewScreen extends StatelessWidget {
  const OnboardingReviewScreen({super.key});

  UserGoals _calculateGoals(OnboardingViewModel vm) {
    final age = vm.age!;
    final weight = vm.weight!;
    final height = vm.height!;
    final gender = vm.gender;

    double tmb;
    if (gender == "masculino") {
      tmb = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      tmb = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    final activityMap = {
      "sedentario": 1.2,
      "leve": 1.375,
      "moderado": 1.55,
      "intenso": 1.725,
    };

    final tdee = tmb * (activityMap[vm.activity] ?? 1.2);

    double targetKcal = tdee;

    switch (vm.goal) {
      case "emagrecer":
        targetKcal -= 300;
        break;
      case "ganhar":
        targetKcal += 300;
        break;
    }

    if (targetKcal < 1200) targetKcal = 1200;

    final protein = weight * 2;
    final fat = (targetKcal * 0.25) / 9;
    final carbs = (targetKcal - (protein * 4) - (fat * 9)) / 4;

    return UserGoals(
      kcal: targetKcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
      goalType: vm.goal == "emagrecer"
          ? "cutting"
          : vm.goal == "ganhar"
              ? "bulking"
              : "maintenance",
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Revisar dados")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Revise suas informações:",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Text("Idade: ${vm.age}"),
            Text("Sexo: ${vm.gender}"),
            Text("Peso: ${vm.weight} kg"),
            Text("Altura: ${vm.height} cm"),
            Text("Atividade: ${vm.activity}"),
            Text("Objetivo: ${vm.goal}"),
            Text("Restrições: ${vm.restrictions.join(', ')}"),
            const Spacer(),
            FilledButton(
              onPressed: () async {
                if (uid != null) {
                  final goals = _calculateGoals(vm);
                  await SettingsRepository.setGoals(uid, goals);

                  await UserRepository.saveOnboardingData(uid, {
                    'age': vm.age,
                    'gender': vm.gender,
                    'weight': vm.weight,
                    'height': vm.height,
                    'activity': vm.activity,
                    'goal': vm.goal,
                    'restrictions': vm.restrictions,
                  });

                  await UserRepository.finishOnboarding(uid);
                }
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyMealScreen()),
                  (_) => false,
                );
              },
              child: const Text("Concluir"),
            ),
          ],
        ),
      ),
    );
  }
}
