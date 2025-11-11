// lib/src/views/home/home_view.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_plan/src/data/meal_repository.dart';
import 'package:nutri_plan/src/models/meal.dart';
import 'package:nutri_plan/src/viewmodels/reports_viewmodel.dart';
import 'package:nutri_plan/src/views/meals/new_meal_view.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // carrega perfil após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserViewModel>().loadCurrent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _MenuInicialPage(),
      const _RefeicoesPage(),
      const _RelatoriosPage(),
      const _ConfiguracoesPage(),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Início'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_outlined),
              selectedIcon: Icon(Icons.restaurant),
              label: 'Refeições'),
          NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Rel.'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Conf.'),
        ],
      ),
    );
  }
}

/// -------------------- PÁGINAS --------------------
class _MenuInicialPage extends StatelessWidget {
  const _MenuInicialPage();

  // metas mockadas (depois puxe de config do usuário)
  static const double goalKcal = 2200;
  static const double goalProt = 150;
  static const double goalCarb = 250;
  static const double goalFat = 70;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Faça login.'));
    final uid = user.uid;

    return StreamBuilder<List<Meal>>(
      stream: MealRepository.watchAll(uid, day: DateTime.now()),
      builder: (context, snap) {
        final meals = snap.data ?? const <Meal>[];
        final totKcal = meals.fold<double>(0, (a, m) => a + m.totalKcal);
        final totProt = meals.fold<double>(0, (a, m) => a + m.totalProtein);
        final totCarb = meals.fold<double>(0, (a, m) => a + m.totalCarbs);
        final totFat = meals.fold<double>(0, (a, m) => a + m.totalFat);
        final kcalLeft = (goalKcal - totKcal).clamp(0, goalKcal);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Menu inicial',
                style: Theme.of(context).textTheme.headlineSmall),

            const SizedBox(height: 12),
            // KPIs
            _KpiTile(
                title: 'Kcal restantes',
                value: '${kcalLeft.toStringAsFixed(0)}',
                progress: (totKcal / goalKcal).clamp(0, 1),
                subtitle:
                    '${totKcal.toStringAsFixed(0)} / ${goalKcal.toStringAsFixed(0)}'),
            _KpiTile(
                title: 'Proteínas (g)',
                value: '${totProt.toStringAsFixed(0)}',
                progress: (totProt / goalProt).clamp(0, 1),
                subtitle: 'Meta: ${goalProt.toStringAsFixed(0)}'),
            _KpiTile(
                title: 'Carboidratos (g)',
                value: '${totCarb.toStringAsFixed(0)}',
                progress: (totCarb / goalCarb).clamp(0, 1),
                subtitle: 'Meta: ${goalCarb.toStringAsFixed(0)}'),
            _KpiTile(
                title: 'Gorduras (g)',
                value: '${totFat.toStringAsFixed(0)}',
                progress: (totFat / goalFat).clamp(0, 1),
                subtitle: 'Meta: ${goalFat.toStringAsFixed(0)}'),

            const SizedBox(height: 8),
            _SectionTitle('Ações rápidas'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickAction(
                    icon: Icons.add,
                    label: 'Nova refeição',
                    onTap: () async {
                      final id = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NewMealView()));
                      if (id != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refeição salva.')));
                      }
                    }),
                _QuickAction(
                    icon: Icons.star_border,
                    label: 'Favoritos',
                    onTap: () {/* TODO */}),
                _QuickAction(
                    icon: Icons.local_drink_outlined,
                    label: 'Água +250ml',
                    onTap: () {/* TODO: hidratação */}),
                _QuickAction(
                    icon: Icons.calendar_month,
                    label: 'Plano semanal',
                    onTap: () {/* TODO */}),
                _QuickAction(
                    icon: Icons.shopping_basket_outlined,
                    label: 'Lista compras',
                    onTap: () {/* TODO */}),
                _QuickAction(
                    icon: Icons.pie_chart_outline,
                    label: 'Relatórios',
                    onTap: () {/* TODO */}),
              ],
            ),

            const SizedBox(height: 16),
            _SectionTitle('Hoje'),
            if (snap.connectionState == ConnectionState.waiting)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (meals.isEmpty)
              const Text('Sem refeições ainda. Use "Nova refeição".')
            else
              ...meals.map((m) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.restaurant_menu),
                      title: Text(m.name),
                      subtitle:
                          Text('${_fmtDate(m.date)} • ${m.items.length} itens'),
                      trailing: Text('${m.totalKcal.toStringAsFixed(0)} kcal',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {/* TODO: detalhes/edição */},
                    ),
                  )),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  static String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final String? subtitle;
  const _KpiTile(
      {super.key,
      required this.title,
      required this.value,
      required this.progress,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(subtitle ?? ''),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 90,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon),
              const Spacer(),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RefeicoesPage extends StatelessWidget {
  const _RefeicoesPage();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Faça login para ver suas refeições.'));
    }
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
              if (snap.hasError) {
                return Center(child: Text('Erro ao carregar: ${snap.error}'));
              }
              final meals = snap.data ?? const <Meal>[];
              if (meals.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Refeições',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text(
                        'Nenhuma refeição ainda. Toque em "Nova refeição".'),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Refeições',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  ...meals.map((m) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.restaurant_menu),
                          title: Text(m.name),
                          subtitle: Text(
                            '${_fmtDate(m.date)} • ${m.items.length} itens',
                          ),
                          trailing: Text(
                            '${m.totalKcal.toStringAsFixed(0)} kcal',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onTap: () {
                            // TODO: tela de detalhes/edição da refeição
                          },
                        ),
                      )),
                  const SizedBox(height: 80), // espaço pro botão flutuante
                ],
              );
            },
          ),
        ),

        // Botão primário fixo na parte de baixo
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton.icon(
              onPressed: () async {
                final id = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewMealView()),
                );
                if (id != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refeição salva.')));
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
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _RelatoriosPage extends StatefulWidget {
  const _RelatoriosPage();
  @override
  State<_RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<_RelatoriosPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsViewModel()..load(),
      child: Consumer<ReportsViewModel>(
        builder: (context, vm, _) {
          final kcalSeries = vm.kcalByDay();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Relatórios',
                  style: Theme.of(context).textTheme.headlineSmall),

              const SizedBox(height: 8),
              // Filtros rápidos
              Wrap(spacing: 8, runSpacing: 8, children: [
                ChoiceChip(
                  label: const Text('Hoje'),
                  selected: vm.range == QuickRange.hoje,
                  onSelected: (_) {
                    vm.setRange(QuickRange.hoje);
                    vm.load();
                  },
                ),
                ChoiceChip(
                  label: const Text('7 dias'),
                  selected: vm.range == QuickRange.seteDias,
                  onSelected: (_) {
                    vm.setRange(QuickRange.seteDias);
                    vm.load();
                  },
                ),
                ChoiceChip(
                  label: const Text('30 dias'),
                  selected: vm.range == QuickRange.trintaDias,
                  onSelected: (_) {
                    vm.setRange(QuickRange.trintaDias);
                    vm.load();
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(vm.range == QuickRange.custom
                      ? _labelRange(vm.customStart, vm.customEnd)
                      : 'Personalizado'),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDateRange:
                          vm.customStart != null && vm.customEnd != null
                              ? DateTimeRange(
                                  start: vm.customStart!, end: vm.customEnd!)
                              : null,
                    );
                    if (picked != null) {
                      vm.setCustom(picked.start, picked.end);
                      vm.load();
                    }
                  },
                ),
              ]),

              const SizedBox(height: 8),
              // Busca por nome
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar por nome da refeição',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) {
                  vm.setQuery(v);
                  vm.load();
                },
              ),

              const SizedBox(height: 12),
              // KPIs agregados do período
              _KpiRow(items: [
                _Kpi(title: 'Kcal', getter: (vm) => vm.totKcal),
                _Kpi(title: 'Prot (g)', getter: (vm) => vm.totProt),
                _Kpi(title: 'Carb (g)', getter: (vm) => vm.totCarb),
                _Kpi(title: 'Gord (g)', getter: (vm) => vm.totFat),
              ], vm: vm),

              const SizedBox(height: 12),
              // "Gráfico" simples: kcal por dia (barras)
              if (kcalSeries.isEmpty)
                const Text('Sem dados para o período.')
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kcal por dia',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ...kcalSeries.entries.map((e) {
                          final label =
                              '${e.key.day.toString().padLeft(2, '0')}/${e.key.month.toString().padLeft(2, '0')}';
                          final max = kcalSeries.values
                              .fold<double>(0, (a, b) => a > b ? a : b);
                          final ratio = max == 0 ? 0.0 : (e.value / max);
                          final frac = ratio.clamp(0.0, 1.0)
                              as double; // <- corrigido: double
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              SizedBox(width: 48, child: Text(label)),
                              Expanded(
                                  child: LinearProgressIndicator(value: frac)),
                              const SizedBox(width: 8),
                              SizedBox(
                                  width: 60,
                                  child: Text('${e.value.toStringAsFixed(0)}')),
                            ]),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              // Lista das refeições do período
              Text('Refeições do período',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              ...vm.meals.map((m) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.restaurant_menu),
                      title: Text(m.name),
                      subtitle:
                          Text('${_fmtDate(m.date)} • ${m.items.length} itens'),
                      trailing: Text('${m.totalKcal.toStringAsFixed(0)} kcal',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {/* TODO: detalhe/edição */},
                    ),
                  )),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  static String _labelRange(DateTime? s, DateTime? e) {
    if (s == null || e == null) return 'Personalizado';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(s.day)}/${two(s.month)}–${two(e.day)}/${two(e.month)}';
  }

  static String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _KpiRow extends StatelessWidget {
  final List<_Kpi> items;
  final ReportsViewModel vm;
  const _KpiRow({required this.items, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map((k) => Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      Text(k.title),
                      const SizedBox(height: 4),
                      Text(k.getter(vm).toStringAsFixed(0),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ]),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _Kpi {
  final String title;
  final double Function(ReportsViewModel) getter;
  const _Kpi({required this.title, required this.getter});
}

class _ConfiguracoesPage extends StatelessWidget {
  const _ConfiguracoesPage();

  String _initials(String? name, String? email) {
    final base = (name?.trim().isNotEmpty == true ? name! : (email ?? ''))
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (base.isEmpty) return 'US';
    final parts = base.split(' ');
    final first = parts.first.characters.first.toUpperCase();
    final last =
        parts.length > 1 ? parts.last.characters.first.toUpperCase() : '';
    return '$first$last';
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final u = userVM.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Configurações', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(_initials(u?.name, u?.email)),
            ),
            title: Text(u?.name ?? 'Usuário'),
            subtitle: Text(u?.email ?? '-'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: navegação para detalhes de perfil
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Geral'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: configurações gerais
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () => context.read<AuthViewModel>().signOut(),
          ),
        ),
        if (userVM.loading)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (userVM.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                Text(userVM.error!, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
}

/// -------------------- WIDGETS DE APOIO --------------------

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _ActionCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 90,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final String title;
  final int kcal;
  final List<String> items;
  const _MealTile(
      {required this.title, required this.kcal, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu),
        title: Text(title),
        subtitle: Text('${items.join(' • ')}'),
        trailing: Text('$kcal kcal',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        onTap: () {},
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing:
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _PlaceholderChart extends StatelessWidget {
  final String title;
  const _PlaceholderChart({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 180,
        child: Center(
          child: Text('Gráfico: $title'),
        ),
      ),
    );
  }
}
