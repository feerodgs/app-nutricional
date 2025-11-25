import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/onboarding_viewmodel.dart';
import 'onboarding_step_activity_screen.dart';

class OnboardingStepWeightHeightView extends StatefulWidget {
  const OnboardingStepWeightHeightView({super.key});

  @override
  State<OnboardingStepWeightHeightView> createState() =>
      _OnboardingStepWeightHeightViewState();
}

class _OnboardingStepWeightHeightViewState
    extends State<OnboardingStepWeightHeightView> {
  late TextEditingController weightCtrl;
  late TextEditingController heightCtrl;

  @override
  void initState() {
    super.initState();
    final vm = context.read<OnboardingViewModel>();

    weightCtrl = TextEditingController(
      text: vm.weight != null ? vm.weight!.toString() : '',
    );

    heightCtrl = TextEditingController(
      text: vm.height != null ? vm.height!.toString() : '',
    );
  }

  double? _parse(String v) {
    final cleaned = v.replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Peso e altura")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informe seu peso e altura",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            // PESO
            TextField(
              controller: weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Peso (kg)"),
              onChanged: (v) {
                final parsed = _parse(v);
                if (parsed != null && parsed > 0) {
                  vm.setWeight(parsed);
                }
              },
            ),

            const SizedBox(height: 16),

            // ALTURA
            TextField(
              controller: heightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Altura (cm)"),
              onChanged: (v) {
                final parsed = _parse(v);
                if (parsed != null && parsed > 0) {
                  vm.setHeight(parsed);
                }
              },
            ),

            const Spacer(),

            FilledButton(
              onPressed: vm.weight != null && vm.height != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingStepActivityView(),
                        ),
                      );
                    }
                  : null,
              child: const Text("Próximo"),
            ),
          ],
        ),
      ),
    );
  }
}
