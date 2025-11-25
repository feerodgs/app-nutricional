import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import 'onboarding_step_plan_duration_view.dart';

class OnboardingStepRestrictionsView extends StatelessWidget {
  const OnboardingStepRestrictionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    final list = [
      "Lactose",
      "Glúten",
      "Vegetariano",
      "Vegano",
      "Alergia a frutos do mar",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Restrições alimentares")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selecione se tiver alguma restrição:",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            ...list.map((r) {
              return CheckboxListTile(
                title: Text(r),
                value: vm.restrictions.contains(r),
                onChanged: (_) => vm.toggleRestriction(r),
              );
            }),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingStepPlanDurationView(),
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
