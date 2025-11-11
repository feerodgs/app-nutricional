// lib/src/views/home/pages/refeicoes_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/meal_repository.dart';
import '../../../models/meal.dart';
import '../../meals/new_meal_view.dart';

class RefeicoesPage extends StatelessWidget {
  const RefeicoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Faça login.'));
    final uid = user.uid;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Meal>>(
            stream: MealRepository.watchAll(uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final meals = snap.data ?? const <Meal>[];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Refeições',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (meals.isEmpty)
                    const Text('Nenhuma refeição ainda.')
                  else
                    ...meals.map((m) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.restaurant_menu),
                            title: Text(m.name),
                            subtitle: Text(
                                '${_fmtDate(m.date)} • ${m.items.length} itens'),
                            trailing: Text(
                                '${m.totalKcal.toStringAsFixed(0)} kcal',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            onTap: () {/* TODO: detalhe/edição */},
                          ),
                        )),
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton.icon(
              onPressed: () async {
                final id = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NewMealView()));
                if (id != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refeição salva.')),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova refeição'),
            ),
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }
}
