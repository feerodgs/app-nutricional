import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/history_viewmodel.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryViewModel()..load(),
      child: Consumer<HistoryViewModel>(
        builder: (context, vm, _) {
          final kcalSeries = vm.kcalByDay();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Histórico',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                ChoiceChip(
                  label: const Text('Hoje'),
                  selected: vm.range == HistoryQuickRange.hoje,
                  onSelected: (_) {
                    vm.setRange(HistoryQuickRange.hoje);
                    vm.load();
                  },
                ),
                ChoiceChip(
                  label: const Text('7 dias'),
                  selected: vm.range == HistoryQuickRange.seteDias,
                  onSelected: (_) {
                    vm.setRange(HistoryQuickRange.seteDias);
                    vm.load();
                  },
                ),
                ChoiceChip(
                  label: const Text('30 dias'),
                  selected: vm.range == HistoryQuickRange.trintaDias,
                  onSelected: (_) {
                    vm.setRange(HistoryQuickRange.trintaDias);
                    vm.load();
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(vm.range == HistoryQuickRange.custom
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
              Row(children: [
                _kpi(context, 'Kcal', vm.totKcal),
                _kpi(context, 'Prot (g)', vm.totProt),
                _kpi(context, 'Carb (g)', vm.totCarb),
                _kpi(context, 'Gord (g)', vm.totFat),
              ]),
              const SizedBox(height: 12),
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
                            final frac = ratio.clamp(0.0, 1.0) as double;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(children: [
                                SizedBox(width: 48, child: Text(label)),
                                Expanded(
                                    child:
                                        LinearProgressIndicator(value: frac)),
                                const SizedBox(width: 8),
                                SizedBox(
                                    width: 60,
                                    child:
                                        Text('${e.value.toStringAsFixed(0)}')),
                              ]),
                            );
                          }),
                        ]),
                  ),
                ),
              const SizedBox(height: 12),
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
                    ),
                  )),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _kpi(BuildContext context, String t, double v) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Text(t),
              const SizedBox(height: 4),
              Text(v.toStringAsFixed(0),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
          ),
        ),
      );

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
