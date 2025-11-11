import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal_item.dart';
import '../../viewmodels/meal_viewmodel.dart';

class NewMealView extends StatelessWidget {
  const NewMealView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MealViewModel(),
      child: const _NewMealScaffold(),
    );
  }
}

class _NewMealScaffold extends StatelessWidget {
  const _NewMealScaffold();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MealViewModel>();
    final nameCtrl = TextEditingController(text: vm.name);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova refeição')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Nome da refeição (ex: Almoço)'),
            onChanged: vm.setName,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Data/hora'),
            subtitle: Text(vm.date.toString()),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDate: vm.date,
              );
              if (d == null) return;
              final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(vm.date));
              final combined = DateTime(
                  d.year, d.month, d.day, t?.hour ?? 12, t?.minute ?? 0);
              vm.setDate(combined);
            },
          ),
          const SizedBox(height: 12),
          Text('Itens', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...vm.items.asMap().entries.map((e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.fastfood),
                  title: Text(e.value.food),
                  subtitle: Text(
                      '${e.value.quantity} ${e.value.unit} • ${e.value.kcal.toStringAsFixed(0)} kcal'),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          context.read<MealViewModel>().removeItem(e.key)),
                ),
              )),
          TextButton.icon(
            onPressed: () async {
              final item = await showDialog<MealItem>(
                context: context,
                builder: (_) => const _AddItemDialog(),
              );
              if (item != null) context.read<MealViewModel>().addItem(item);
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar item'),
          ),
          const SizedBox(height: 16),
          if (vm.error != null)
            Text(vm.error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          vm.saving
              ? const Center(child: CircularProgressIndicator())
              : FilledButton.icon(
                  onPressed: () async {
                    final id = await context.read<MealViewModel>().save();
                    if (id != null && context.mounted) {
                      Navigator.pop(context, id); // volta para lista
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar refeição'),
                ),
        ],
      ),
    );
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
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _qty,
                        decoration: const InputDecoration(labelText: 'Qtd'),
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                SizedBox(
                    width: 80,
                    child: TextFormField(
                        controller: _unit,
                        decoration: const InputDecoration(labelText: 'Unid'))),
              ]),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _kcal,
                        decoration: const InputDecoration(labelText: 'Kcal'),
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _protein,
                        decoration:
                            const InputDecoration(labelText: 'Prot (g)'),
                        keyboardType: TextInputType.number)),
              ]),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _carbs,
                        decoration:
                            const InputDecoration(labelText: 'Carb (g)'),
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(
                    child: TextFormField(
                        controller: _fat,
                        decoration:
                            const InputDecoration(labelText: 'Gord (g)'),
                        keyboardType: TextInputType.number)),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (!_f.currentState!.validate()) return;
            final item = MealItem(
              food: _food.text.trim(),
              quantity: double.tryParse(_qty.text) ?? 0,
              unit: _unit.text.trim(),
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
