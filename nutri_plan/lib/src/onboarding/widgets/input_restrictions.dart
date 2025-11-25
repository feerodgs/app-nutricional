import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class InputRestrictions extends StatelessWidget {
  final VoidCallback onNext;
  const InputRestrictions({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    final options = [
      "lactose",
      "gluten",
      "oleaginosa",
      "frutos do mar",
      "ovo",
      "nenhuma"
    ];

    return Column(
      children: [
        ...options.map((r) {
          final selected = vm.restrictions.contains(r);
          return CheckboxListTile(
            title: Text(r),
            value: selected,
            onChanged: (_) => vm.toggleRestriction(r),
          );
        }),
        const Spacer(),
        FilledButton(
          onPressed: onNext,
          child: const Text("Finalizar"),
        )
      ],
    );
  }
}
