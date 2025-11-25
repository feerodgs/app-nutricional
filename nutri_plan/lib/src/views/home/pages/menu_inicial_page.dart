import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/meal_repository.dart';
import '../../../data/settings_repository.dart';
import '../../../models/meal.dart';
import '../../../models/user_goals.dart';
import '../../home/widgets/kpi_tile.dart';

double _clamp01(double x) => x < 0 ? 0.0 : (x > 1 ? 1.0 : x);

class MenuInicialPage extends StatelessWidget {
  const MenuInicialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Faça login.'));
    }

    final uid = user.uid;

    return StreamBuilder<UserGoals>(
      stream: SettingsRepository.watchGoals(uid),
      builder: (context, gSnap) {
        final goals = gSnap.data ?? UserGoals.defaults;

        return StreamBuilder<List<Meal>>(
          stream: MealRepository.watchAll(uid, day: DateTime.now()),
          initialData: const <Meal>[],
          builder: (context, snap) {
            final allMeals = snap.data ?? const <Meal>[];

            // Apenas refeições realizadas
            final doneMeals = allMeals.where((m) => m.done).toList();

            final totKcal = doneMeals.fold(0.0, (a, m) => a + m.totalKcal);
            final totProt = doneMeals.fold(0.0, (a, m) => a + m.totalProtein);
            final totCarb = doneMeals.fold(0.0, (a, m) => a + m.totalCarbs);
            final totFat = doneMeals.fold(0.0, (a, m) => a + m.totalFat);

            final kcalLeft = (goals.kcal - totKcal).clamp(0, goals.kcal);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Menu inicial',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),

                // KPIs — somente refeições concluídas
                KpiTile(
                  title: 'Kcal restantes',
                  value: kcalLeft.toStringAsFixed(0),
                  subtitle:
                      '${totKcal.toStringAsFixed(0)} / ${goals.kcal.toStringAsFixed(0)}',
                  progress:
                      goals.kcal <= 0 ? 0 : _clamp01(totKcal / goals.kcal),
                ),
                KpiTile(
                  title: 'Proteínas (g)',
                  value: totProt.toStringAsFixed(0),
                  subtitle: 'Meta: ${goals.protein.toStringAsFixed(0)}',
                  progress: goals.protein <= 0
                      ? 0
                      : _clamp01(totProt / goals.protein),
                ),
                KpiTile(
                  title: 'Carboidratos (g)',
                  value: totCarb.toStringAsFixed(0),
                  subtitle: 'Meta: ${goals.carbs.toStringAsFixed(0)}',
                  progress:
                      goals.carbs <= 0 ? 0 : _clamp01(totCarb / goals.carbs),
                ),
                KpiTile(
                  title: 'Gorduras (g)',
                  value: totFat.toStringAsFixed(0),
                  subtitle: 'Meta: ${goals.fat.toStringAsFixed(0)}',
                  progress: goals.fat <= 0 ? 0 : _clamp01(totFat / goals.fat),
                ),

                const SizedBox(height: 16),

                Text('Hoje', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),

                if (snap.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (allMeals.isEmpty)
                  const Text('Sem refeições ainda.')
                else
                  ...allMeals.map(
                    (m) => Card(
                      color: m.done ? Colors.green.shade50 : null,
                      child: ListTile(
                        leading: Icon(
                          m.done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: m.done ? Colors.green : Colors.grey,
                        ),
                        title: Text(m.name),
                        subtitle: Text(
                            '${_fmtTime(m.date)} • ${m.items.length} itens'),
                        trailing: Text(
                          '${m.totalKcal.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            );
          },
        );
      },
    );
  }

  String _fmtTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}';
  }
}
