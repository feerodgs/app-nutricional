import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import 'onboarding_step_restrictions_screen.dart';

class OnboardingStepGoalView extends StatelessWidget {
  const OnboardingStepGoalView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    final goals = {
      "emagrecer": "Emagrecer",
      "manter": "Manter peso",
      "ganhar": "Ganhar massa",
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Seu objetivo")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Qual seu objetivo?",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            ...goals.entries.map(
              (e) => RadioListTile(
                title: Text(e.value),
                value: e.key,
                groupValue: vm.goal,
                onChanged: (v) => vm.setGoal(v!),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: vm.goal == null
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const OnboardingStepRestrictionsView(),
                        ),
                      ),
              child: const Text("Próximo"),
            ),
          ],
        ),
      ),
    );
  }
}
