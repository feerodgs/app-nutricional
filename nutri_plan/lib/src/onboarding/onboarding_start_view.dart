import 'package:flutter/material.dart';
import 'onboarding_flow.dart';

class OnboardingStartView extends StatelessWidget {
  const OnboardingStartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bem-vindo ao NutriPlan",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              "Vamos personalizar seu plano alimentar com base nos seus dados.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingFlow(),
                  ),
                );
              },
              child: const Text("Começar"),
            ),
          ],
        ),
      ),
    );
  }
}
