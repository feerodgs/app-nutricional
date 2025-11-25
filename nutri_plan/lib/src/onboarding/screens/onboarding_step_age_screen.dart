import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/onboarding_viewmodel.dart';
import 'onboarding_step_gender_screen.dart';

class OnboardingStepAgeView extends StatefulWidget {
  const OnboardingStepAgeView({super.key});

  @override
  State<OnboardingStepAgeView> createState() => _OnboardingStepAgeViewState();
}

class _OnboardingStepAgeViewState extends State<OnboardingStepAgeView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    final vm = context.read<OnboardingViewModel>();

    _controller = TextEditingController(
      text: vm.age?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Idade")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quantos anos você tem?",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Campo de idade
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Idade"),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed > 0) {
                  vm.setAge(parsed);
                } else {
                  vm.setAge(0); // limpa se inválido
                }
              },
            ),

            const Spacer(),

            // Botão
            FilledButton(
              onPressed: (vm.age != null && vm.age! > 0)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingStepGenderView(),
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
