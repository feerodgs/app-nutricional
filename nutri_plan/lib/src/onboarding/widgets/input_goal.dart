import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class InputGoal extends StatelessWidget {
  final VoidCallback onNext;
  const InputGoal({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Column(
      children: [
        RadioListTile(
          title: const Text("Perder peso"),
          value: "cutting",
          groupValue: vm.goal,
          onChanged: (v) => vm.setGoal(v!),
        ),
        RadioListTile(
          title: const Text("Manter peso"),
          value: "maintenance",
          groupValue: vm.goal,
          onChanged: (v) => vm.setGoal(v!),
        ),
        RadioListTile(
          title: const Text("Ganhar massa"),
          value: "bulking",
          groupValue: vm.goal,
          onChanged: (v) => vm.setGoal(v!),
        ),
        const Spacer(),
        FilledButton(
          onPressed: vm.goal == null ? null : onNext,
          child: const Text("Continuar"),
        )
      ],
    );
  }
}
