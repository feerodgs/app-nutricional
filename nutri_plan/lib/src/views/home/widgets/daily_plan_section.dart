import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../viewmodels/daily_meal_viewmodel.dart';

class DailyPlanSection extends StatelessWidget {
  const DailyPlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Consumer<DailyMealViewModel>(
      builder: (context, vm, _) {
        if (vm.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (vm.meals.isEmpty) {
          return Column(
            children: [
              const Text("Nenhum plano gerado para hoje."),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => vm.load(uid),
                child: const Text("Gerar plano do dia"),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Plano do dia",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...vm.meals.map((m) {
              return Card(
                child: ListTile(
                  title: Text(m.name),
                  subtitle: Text(
                    "${m.items.length} itens • ${m.totalKcal.toStringAsFixed(0)} kcal",
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
