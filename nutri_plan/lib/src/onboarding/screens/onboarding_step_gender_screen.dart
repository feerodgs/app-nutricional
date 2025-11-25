import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import 'onboarding_step_weight_height_screen.dart';

class OnboardingStepGenderView extends StatelessWidget {
  const OnboardingStepGenderView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Sexo")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selecione seu sexo",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
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
              onPressed: vm.gender == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const OnboardingStepWeightHeightView(),
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
