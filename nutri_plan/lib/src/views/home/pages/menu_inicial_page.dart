// lib/src/views/home/pages/menu_inicial_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/meal_repository.dart';
import '../../../models/meal.dart';
import '../../meals/new_meal_view.dart';
import '../../home/widgets/kpi_tile.dart';
import '../../home/widgets/quick_action_card.dart';
import './historico_page.dart'; // navegação para histórico

// mock metas (substituir por SettingsRepository se já tiver)
const double _goalKcal = 2200, _goalProt = 150, _goalCarb = 250, _goalFat = 70;
double _clamp01(double x) => x < 0 ? 0.0 : (x > 1 ? 1.0 : x);

class MenuInicialPage extends StatelessWidget {
  const MenuInicialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Faça login.'));
    final uid = user.uid;

    return StreamBuilder<List<Meal>>(
      stream: MealRepository.watchAll(uid, day: DateTime.now()),
      initialData: const <Meal>[],
      builder: (context, snap) {
        final meals = snap.data ?? const <Meal>[];

        final totKcal = meals.fold<double>(0, (a, m) => a + m.totalKcal);
        final totProt = meals.fold<double>(0, (a, m) => a + m.totalProtein);
        final totCarb = meals.fold<double>(0, (a, m) => a + m.totalCarbs);
        final totFat = meals.fold<double>(0, (a, m) => a + m.totalFat);

        final kcalLeft = (_goalKcal - totKcal).clamp(0, _goalKcal);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Menu inicial',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            KpiTile(
              title: 'Kcal restantes',
              value: '${kcalLeft.toStringAsFixed(0)}',
              subtitle:
                  '${totKcal.toStringAsFixed(0)} / ${_goalKcal.toStringAsFixed(0)}',
              progress: _clamp01(totKcal / _goalKcal),
            ),
            KpiTile(
              title: 'Proteínas (g)',
              value: '${totProt.toStringAsFixed(0)}',
              subtitle: 'Meta: ${_goalProt.toStringAsFixed(0)}',
              progress: _clamp01(totProt / _goalProt),
            ),
            KpiTile(
              title: 'Carboidratos (g)',
              value: '${totCarb.toStringAsFixed(0)}',
              subtitle: 'Meta: ${_goalCarb.toStringAsFixed(0)}',
              progress: _clamp01(totCarb / _goalCarb),
            ),
            KpiTile(
              title: 'Gorduras (g)',
              value: '${totFat.toStringAsFixed(0)}',
              subtitle: 'Meta: ${_goalFat.toStringAsFixed(0)}',
              progress: _clamp01(totFat / _goalFat),
            ),
            const SizedBox(height: 8),
            Text('Ações rápidas',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Wrap(spacing: 12, runSpacing: 12, children: [
              // Nova refeição
              QuickActionCard(
                icon: Icons.add,
                label: 'Nova refeição',
                onTap: () async {
                  final id = await Navigator.push(
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

              // Água
              const QuickActionCard(
                icon: Icons.local_drink_outlined,
                label: 'Água +250ml',
              ),

              // Montar plano por IA (placeholder de navegação)
              QuickActionCard(
                icon: Icons.smart_toy_outlined,
                label: 'Montar plano por IA',
                onTap: () {
                  // TODO: navegar para a tela/flow de IA
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Em breve: plano por IA')),
                  );
                },
              ),

              // Histórico (antes era "Resumo")
              QuickActionCard(
                icon: Icons.history,
                label: 'Histórico',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoricoPage()),
                  );
                },
              ),
            ]),
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
            else if (meals.isEmpty)
              const Text('Sem refeições ainda. Use "Nova refeição".')
            else
              ...meals.map((m) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.restaurant_menu),
                      title: Text(m.name),
                      subtitle:
                          Text('${_fmtTime(m.date)} • ${m.items.length} itens'),
                      trailing: Text(
                        '${m.totalKcal.toStringAsFixed(0)} kcal',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      // se quiser abrir edição ao tocar:
                      // onTap: () => Navigator.push(... EditMealView(meal: m)),
                    ),
                  )),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  String _fmtTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}';
  }
}
