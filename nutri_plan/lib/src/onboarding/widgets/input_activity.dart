import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class InputActivity extends StatelessWidget {
  final VoidCallback onNext;
  const InputActivity({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Column(
      children: [
        RadioListTile(
          title: const Text("Sedentário"),
          value: "sedentario",
          groupValue: vm.activity,
          onChanged: (v) => vm.setActivity(v!),
        ),
        RadioListTile(
          title: const Text("Moderado"),
          value: "moderado",
          groupValue: vm.activity,
          onChanged: (v) => vm.setActivity(v!),
        ),
        RadioListTile(
          title: const Text("Intenso"),
          value: "intenso",
          groupValue: vm.activity,
          onChanged: (v) => vm.setActivity(v!),
        ),
        const Spacer(),
        FilledButton(
          onPressed: vm.activity == null ? null : onNext,
          child: const Text("Continuar"),
        )
      ],
    );
  }
}
