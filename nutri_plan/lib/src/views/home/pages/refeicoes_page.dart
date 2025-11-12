import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_plan/src/views/meals/edit_meal_view.dart';
import '../../../data/meal_repository.dart';
import '../../../models/meal.dart';
import '../../meals/new_meal_view.dart';

class RefeicoesPage extends StatelessWidget {
  const RefeicoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Faça login para ver suas refeições.'));
    }
    final uid = user.uid;
    final today = DateTime.now();

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Meal>>(
            stream: MealRepository.watchAll(uid, day: today), // só hoje
            initialData: const <Meal>[],
            builder: (context, snap) {
              final meals = snap.data ?? const <Meal>[];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Refeições de hoje',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (meals.isEmpty &&
                      snap.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (meals.isEmpty)
                    const Text('Nenhuma refeição hoje.'),
                  if (meals.isNotEmpty)
                    ...meals.map((m) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.restaurant_menu),
                            title: Text(m.name),
                            subtitle: Text(
                                '${_fmtTime(m.date)} • ${m.items.length} itens'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${m.totalKcal.toStringAsFixed(0)} kcal',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Excluir',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Excluir refeição'),
                                        content: Text(
                                            'Remover "${m.name}"? Esta ação não pode ser desfeita.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      try {
                                        await MealRepository.delete(uid, m.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Refeição excluída.')),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Erro ao excluir: $e')),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              final updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => EditMealView(meal: m)),
                              );
                              if (updated == true && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Refeição atualizada.')),
                                );
                              }
                            },
                          ),
                        )),
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Nova refeição'),
              onPressed: () async {
                final id = await Navigator.push<String?>(
                  context,
                  MaterialPageRoute(builder: (_) => const NewMealView()),
                );
                if (id != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refeição salva.')),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  static String _fmtTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}';
  }
}
