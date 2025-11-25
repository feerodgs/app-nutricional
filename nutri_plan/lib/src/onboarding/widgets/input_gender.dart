import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class InputGender extends StatelessWidget {
  final VoidCallback onNext;
  const InputGender({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile(
          title: const Text("Masculino"),
          value: "masculino",
          groupValue: vm.gender,
          onChanged: (v) => vm.setGender(v!),
        ),
        RadioListTile(
          title: const Text("Feminino"),
          value: "feminino",
          groupValue: vm.gender,
          onChanged: (v) => vm.setGender(v!),
        ),
        const Spacer(),
        FilledButton(
          onPressed: vm.gender == null ? null : onNext,
          child: const Text("Continuar"),
        )
      ],
    );
  }
}
