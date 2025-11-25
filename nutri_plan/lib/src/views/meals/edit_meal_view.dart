import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/meal_repository.dart';
import '../../models/meal.dart';
import '../../models/meal_item.dart';

class EditMealView extends StatelessWidget {
  final Meal meal;
  const EditMealView({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _MealEditVM(meal),
      child: const _EditMealPage(),
    );
  }
}

class _EditMealPage extends StatefulWidget {
  const _EditMealPage();

  @override
  State<_EditMealPage> createState() => _EditMealPageState();
}

class _EditMealPageState extends State<_EditMealPage> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final vm = context.read<_MealEditVM>();
    _nameCtrl = TextEditingController(text: vm.name);
    _nameCtrl.addListener(() {
      if (vm.name != _nameCtrl.text) vm.setName(_nameCtrl.text);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<_MealEditVM>();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar refeição')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            enabled: !vm.saving,
            decoration: const InputDecoration(labelText: 'Nome da refeição'),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Data/hora'),
            subtitle: Text(_fmt(vm.date)),
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
                    vm.setDate(DateTime(
                      d.year,
                      d.month,
                      d.day,
                      t?.hour ?? 12,
                      t?.minute ?? 0,
                    ));
                  },
          ),
          const SizedBox(height: 12),
          Text('Itens', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          if (vm.items.isEmpty)
            const Text('Nenhum item. Use "Adicionar item".')
          else
            ...vm.items.asMap().entries.map((e) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.fastfood),
                    title: Text(e.value.food),
                    subtitle: Text(
                      '${e.value.quantity} ${e.value.unit} • ${e.value.kcal.toStringAsFixed(0)} kcal',
                    ),
                    onTap: vm.saving
                        ? null
                        : () async {
                            final edited = await showDialog<MealItem>(
                              context: context,
                              builder: (_) => _ItemDialog(initial: e.value),
                            );
                            if (edited != null && context.mounted) {
                              vm.updateItem(e.key, edited);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Item atualizado.')),
                              );
                            }
                          },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: vm.saving ? null : () => vm.removeItem(e.key),
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
                      builder: (_) => const _ItemDialog(),
                    );
                    if (item != null) vm.addItem(item);
                  },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar item'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: vm.done,
            title: const Text("Refeição concluída"),
            onChanged: vm.saving ? null : vm.setDone,
          ),
          if (vm.error != null) ...[
            const SizedBox(height: 8),
            Text(vm.error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: vm.saving
                ? null
                : () async {
                    final ok = await vm.save();
                    if (!mounted) return;
                    if (ok) {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Refeição atualizada.')),
                      );
                    } else if (vm.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(vm.error!)),
                      );
                    }
                  },
            icon: vm.saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(vm.saving ? 'Salvando...' : 'Salvar alterações'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _MealEditVM extends ChangeNotifier {
  final String mealId;
  final String uid;

  String name;
  DateTime date;
  final List<MealItem> items;
  bool done;

  bool saving = false;
  String? error;

  _MealEditVM(Meal m)
      : mealId = m.id,
        uid = m.userId,
        name = m.name,
        date = m.date,
        items = List<MealItem>.from(m.items),
        done = m.done;

  void setName(String v) {
    name = v;
    notifyListeners();
  }

  void setDate(DateTime v) {
    date = v;
    notifyListeners();
  }

  void setDone(bool v) {
    done = v;
    notifyListeners();
  }

  void addItem(MealItem i) {
    items.add(i);
    notifyListeners();
  }

  void removeItem(int idx) {
    items.removeAt(idx);
    notifyListeners();
  }

  void updateItem(int index, MealItem item) {
    if (index < 0 || index >= items.length) return;
    items[index] = item;
    notifyListeners();
  }

  Future<bool> save() async {
    if (name.trim().isEmpty) {
      error = 'Informe o nome';
      notifyListeners();
      return false;
    }
    if (items.isEmpty) {
      error = 'Adicione pelo menos um item';
      notifyListeners();
      return false;
    }

    saving = true;
    error = null;
    notifyListeners();

    try {
      final updated = {
        'name': name.trim(),
        'date': Timestamp.fromDate(date),
        'items': items.map((e) => e.toJson()).toList(),
        'done': done,
      };

      await MealRepository.update(uid, mealId, updated);

      saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      saving = false;
      error = 'Erro ao salvar alterações';
      notifyListeners();
      return false;
    }
  }
}

class _ItemDialog extends StatefulWidget {
  final MealItem? initial;
  const _ItemDialog({this.initial});

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final _f = GlobalKey<FormState>();
  late final TextEditingController _food;
  late final TextEditingController _qty;
  late final TextEditingController _unit;
  late final TextEditingController _kcal;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _food = TextEditingController(text: i?.food ?? '');
    _qty = TextEditingController(text: (i?.quantity ?? 100).toString());
    _unit = TextEditingController(text: i?.unit ?? 'g');
    _kcal = TextEditingController(text: (i?.kcal ?? 0).toString());
    _protein = TextEditingController(text: (i?.protein ?? 0).toString());
    _carbs = TextEditingController(text: (i?.carbs ?? 0).toString());
    _fat = TextEditingController(text: (i?.fat ?? 0).toString());
  }

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
    final isEdit = widget.initial != null;

    return AlertDialog(
      title: Text(isEdit ? 'Editar item' : 'Adicionar item'),
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
              Row(
                children: [
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
                ],
              ),
              Row(
                children: [
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
                ],
              ),
              Row(
                children: [
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
                ],
              ),
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
          child: Text(isEdit ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }
}
