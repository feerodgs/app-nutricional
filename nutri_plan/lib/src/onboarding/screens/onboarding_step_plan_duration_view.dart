import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import 'onboarding_review_screen.dart';

class OnboardingStepPlanDurationView extends StatelessWidget {
  const OnboardingStepPlanDurationView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final ctrl = TextEditingController(text: "30");

    return Scaffold(
      appBar: AppBar(title: const Text("Duração do plano")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Por quantos dias deseja seguir este plano?",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Dias (1–90)"),
              onChanged: (_) {},
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingReviewScreen(),
                  ),
                );
              },
              child: const Text("Próximo"),
            ),
          ],
        ),
      ),
    );
  }
}
