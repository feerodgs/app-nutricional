import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class InputAge extends StatelessWidget {
  final VoidCallback onNext;
  const InputAge({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final ctrl = TextEditingController(text: vm.age?.toString() ?? '');

    return Column(
      children: [
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Idade"),
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null) vm.setAge(n);
          },
        ),
        const Spacer(),
        FilledButton(
          onPressed: vm.age == null ? null : onNext,
          child: const Text("Continuar"),
        )
      ],
    );
  }
}
