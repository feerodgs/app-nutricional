import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/settings_repository.dart';
import '../../models/user_goals.dart';
import '../../services/daily_meal_service.dart';

class MealGenerationConfigScreen extends StatefulWidget {
  const MealGenerationConfigScreen({super.key});

  @override
  State<MealGenerationConfigScreen> createState() =>
      _MealGenerationConfigScreenState();
}

class _MealGenerationConfigScreenState
    extends State<MealGenerationConfigScreen> {
  int mealsPerDay = 4;
  int numberOfDays = 1;
  TimeOfDay breakfast = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay lunch = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay snack = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay dinner = const TimeOfDay(hour: 19, minute: 0);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<UserGoals>(
      future: SettingsRepository.getGoals(uid),
      builder: (context, snap) {
        final goals = snap.data;

        return Scaffold(
          appBar: AppBar(title: const Text("Configurar geração")),
          body: snap.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      "Suas metas",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "Kcal: ${goals!.kcal.toStringAsFixed(0)}  •  "
                      "Proteína: ${goals.protein.toStringAsFixed(0)}g  •  "
                      "Carboidratos: ${goals.carbs.toStringAsFixed(0)}g  •  "
                      "Gorduras: ${goals.fat.toStringAsFixed(0)}g",
                    ),
                    const SizedBox(height: 24),

                    // Quantidade de refeições
                    Text("Quantidade de refeições por dia"),
                    Slider(
                      value: mealsPerDay.toDouble(),
                      min: 3,
                      max: 6,
                      divisions: 3,
                      label: mealsPerDay.toString(),
                      onChanged: (v) => setState(() {
                        mealsPerDay = v.toInt();
                      }),
                    ),
                    Text("Refeições: $mealsPerDay"),
                    const SizedBox(height: 16),

                    // Quantos dias gerar
                    Text("Gerar para quantos dias?"),
                    Slider(
                      value: numberOfDays.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      label: "$numberOfDays dias",
                      onChanged: (v) => setState(() {
                        numberOfDays = v.toInt();
                      }),
                    ),
                    Text("$numberOfDays dia(s)"),

                    const SizedBox(height: 24),

                    // Horários
                    Text("Horários das refeições",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),

                    _timeTile("Café da manhã", breakfast, (t) {
                      setState(() => breakfast = t);
                    }),
                    _timeTile("Almoço", lunch, (t) {
                      setState(() => lunch = t);
                    }),
                    _timeTile("Lanche", snack, (t) {
                      setState(() => snack = t);
                    }),
                    _timeTile("Jantar", dinner, (t) {
                      setState(() => dinner = t);
                    }),

                    const SizedBox(height: 32),

                    FilledButton(
                      onPressed: () async {
                        await DailyMealService.generateWithParams(
                          uid: uid,
                          days: numberOfDays,
                          mealsPerDay: mealsPerDay,
                          times: [
                            breakfast,
                            lunch,
                            snack,
                            dinner,
                          ],
                          goals: goals,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Refeições geradas com sucesso!")),
                          );
                        }
                      },
                      child: const Text("Gerar refeições"),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _timeTile(String label, TimeOfDay time, Function(TimeOfDay) onPick) {
    return ListTile(
      title: Text(label),
      trailing: Text(
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"),
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (t != null) onPick(t);
      },
    );
  }
}
