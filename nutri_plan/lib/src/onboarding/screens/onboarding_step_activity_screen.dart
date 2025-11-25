import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import 'onboarding_step_goal_screen.dart';

class OnboardingStepActivityView extends StatelessWidget {
  const OnboardingStepActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    final options = {
      "sedentario": "Sedentário",
      "leve": "Atividade leve",
      "moderado": "Atividade moderada",
      "intenso": "Atividade intensa",
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Nível de atividade")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Qual seu nível de atividade?",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            ...options.entries.map(
              (e) => RadioListTile(
                title: Text(e.value),
                value: e.key,
                groupValue: vm.activity,
                onChanged: (v) => vm.setActivity(v!),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: vm.activity == null
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingStepGoalView(),
                        ),
                      ),
              child: const Text("Próximo"),
            )
          ],
        ),
      ),
    );
  }
}
