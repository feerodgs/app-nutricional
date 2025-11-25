import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class InputWeightHeight extends StatelessWidget {
  final VoidCallback onNext;
  const InputWeightHeight({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    final weightCtrl = TextEditingController(text: vm.weight?.toString() ?? '');
    final heightCtrl = TextEditingController(text: vm.height?.toString() ?? '');

    return Column(
      children: [
        TextField(
          controller: weightCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Peso (kg)"),
          onChanged: (v) =>
              vm.setWeight(double.tryParse(v) ?? (vm.weight ?? 0)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: heightCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Altura (cm)"),
          onChanged: (v) =>
              vm.setHeight(double.tryParse(v) ?? (vm.height ?? 0)),
        ),
        const Spacer(),
        FilledButton(
          onPressed: vm.weight == null || vm.height == null ? null : onNext,
          child: const Text("Continuar"),
        )
      ],
    );
  }
}
