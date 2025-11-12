import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                        initialDate: vm.date);
                    if (d == null) return;
                    final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(vm.date));
                    vm.setDate(DateTime(
                        d.year, d.month, d.day, t?.hour ?? 12, t?.minute ?? 0));
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
                        '${e.value.quantity} ${e.value.unit} • ${e.value.kcal.toStringAsFixed(0)} kcal'),
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
                        builder: (_) => const _AddItemDialog());
                    if (item != null) vm.addItem(item);
                  },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar item'),
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Refeição atualizada.')));
                    } else if (vm.error != null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(vm.error!)));
                    }
                  },
            icon: vm.saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
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

// ---------- VM local de edição ----------
class _MealEditVM extends ChangeNotifier {
  final String mealId;
  final String uid;

  String name;
  DateTime date;
  final List<MealItem> items;

  bool saving = false;
  String? error;

  _MealEditVM(Meal m)
      : mealId = m.id,
        uid = m.userId,
        name = m.name,
        date = m.date,
        items = List<MealItem>.from(m.items);

  void setName(String v) {
    name = v;
    notifyListeners();
  }

  void setDate(DateTime v) {
    date = v;
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
      final updated = Meal(
          id: mealId,
          userId: uid,
          name: name.trim(),
          date: date,
          items: List.of(items));
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

// ---------- Diálogo para adicionar item ----------
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
          child: Column(children: [
            TextFormField(
                controller: _food,
                decoration: const InputDecoration(labelText: 'Alimento'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      controller: _qty,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Qtd'))),
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
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Kcal'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextFormField(
                      controller: _protein,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Prot (g)'))),
            ]),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      controller: _carbs,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Carb (g)'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextFormField(
                      controller: _fat,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Gord (g)'))),
            ]),
          ]),
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
