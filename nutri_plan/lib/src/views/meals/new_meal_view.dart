import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal_item.dart';
import '../../viewmodels/meal_viewmodel.dart';
import '../home/home_view.dart';

class NewMealView extends StatelessWidget {
  const NewMealView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MealViewModel(),
      child: const _NewMealPage(),
    );
  }
}

class _NewMealPage extends StatefulWidget {
  const _NewMealPage();

  @override
  State<_NewMealPage> createState() => _NewMealPageState();
}

class _NewMealPageState extends State<_NewMealPage> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final vm = context.read<MealViewModel>();
    _nameCtrl = TextEditingController(text: vm.name);
    _nameCtrl.addListener(() {
      final v = _nameCtrl.text;
      if (vm.name != v) vm.setName(v); // evita ciclo de rebuild
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MealViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nova refeição')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome da refeição (ex: Almoço)',
            ),
            enabled: !vm.saving,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Data/hora'),
            subtitle: Text(_fmtDateTime(vm.date)),
            onTap: vm.saving
                ? null
                : () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: vm.date,
                    );
                    if (d == null) return;
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(vm.date),
                    );
                    final combined = DateTime(
                        d.year, d.month, d.day, t?.hour ?? 12, t?.minute ?? 0);
                    vm.setDate(combined);
                  },
          ),
          const SizedBox(height: 12),
          Text('Itens', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          if (vm.items.isEmpty)
            const Text('Nenhum item. Toque em "Adicionar item".')
          else
            ...vm.items.asMap().entries.map((e) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.fastfood),
                    title: Text(e.value.food),
                    subtitle: Text(
                        '${e.value.quantity} ${e.value.unit} • ${e.value.kcal.toStringAsFixed(0)} kcal'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: vm.saving
                          ? null
                          : () =>
                              context.read<MealViewModel>().removeItem(e.key),
                    ),
                  ),
                )),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: vm.saving
                ? null
                : () async {
                    final item = await showDialog<MealItem>(
                      context: context,
                      builder: (_) => const _AddItemDialog(),
                    );
                    if (item != null) {
                      context.read<MealViewModel>().addItem(item);
                    }
                  },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar item'),
          ),
          if (vm.error != null) ...[
            const SizedBox(height: 12),
            Text(vm.error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: vm.saving
                ? null
                : () async {
                    final vmLocal = context.read<MealViewModel>();
                    final id = await vmLocal.save();
                    if (!mounted) return;

                    if (id == null) {
                      final msg = vmLocal.error ?? 'Falha ao salvar.';
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(msg)));
                      return;
                    }

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const HomeView(initialIndex: 1)),
                      (_) => false,
                    );
                  },
            icon: vm.saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(vm.saving ? 'Salvando...' : 'Salvar refeição'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fmtDateTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _f = GlobalKey<FormState>();
  final _food = TextEditingController();
  final _qty = TextEditingController(text: '100');
  final _unit = TextEditingController(text: 'g');
  final _kcal = TextEditingController(text: '0');
  final _protein = TextEditingController(text: '0');
  final _carbs = TextEditingController(text: '0');
  final _fat = TextEditingController(text: '0');

  @override
  void dispose() {
    _food.dispose();
    _qty.dispose();
    _unit.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar item'),
      content: Form(
        key: _f,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _food,
                decoration: const InputDecoration(labelText: 'Alimento'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _qty,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qtd'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _unit,
                    decoration: const InputDecoration(labelText: 'Unid'),
                  ),
                ),
              ]),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _kcal,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Kcal'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _protein,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Prot (g)'),
                  ),
                ),
              ]),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _carbs,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Carb (g)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fat,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Gord (g)'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_f.currentState!.validate()) return;
            final item = MealItem(
              food: _food.text.trim(),
              quantity: double.tryParse(_qty.text) ?? 0,
              unit: _unit.text.trim().isEmpty ? 'g' : _unit.text.trim(),
              kcal: double.tryParse(_kcal.text) ?? 0,
              protein: double.tryParse(_protein.text) ?? 0,
              carbs: double.tryParse(_carbs.text) ?? 0,
              fat: double.tryParse(_fat.text) ?? 0,
            );
            Navigator.pop(context, item);
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
