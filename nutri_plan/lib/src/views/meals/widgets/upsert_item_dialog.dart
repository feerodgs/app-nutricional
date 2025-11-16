import 'package:flutter/material.dart';
import '../../../models/meal_item.dart';

class UpsertItemDialog extends StatefulWidget {
  final MealItem? initial;
  const UpsertItemDialog({super.key, this.initial});

  @override
  State<UpsertItemDialog> createState() => _UpsertItemDialogState();
}

class _UpsertItemDialogState extends State<UpsertItemDialog> {
  final _f = GlobalKey<FormState>();

  late TextEditingController _food;
  late TextEditingController _qty;
  late TextEditingController _kcal;
  late TextEditingController _protein;
  late TextEditingController _carbs;
  late TextEditingController _fat;

  String _unit = 'g';
  bool _autoKcal = false; // se true, kcal = 4p + 4c + 9f

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _food = TextEditingController(text: i?.food ?? '');
    _qty = TextEditingController(text: _fmtNum(i?.quantity ?? 100));
    _unit = i?.unit ?? 'g';
    _kcal = TextEditingController(text: _fmtNum(i?.kcal ?? 0));
    _protein = TextEditingController(text: _fmtNum(i?.protein ?? 0));
    _carbs = TextEditingController(text: _fmtNum(i?.carbs ?? 0));
    _fat = TextEditingController(text: _fmtNum(i?.fat ?? 0));
  }

  @override
  void dispose() {
    _food.dispose();
    _qty.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  String _fmtNum(num n) =>
      (n == n.roundToDouble()) ? n.toStringAsFixed(0) : n.toString();

  double _v(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  void _step(TextEditingController c, double delta, {double min = 0}) {
    final v = _v(c) + delta;
    final nv = v < min ? min : v;
    c.text = nv.toStringAsFixed(nv.truncateToDouble() == nv ? 0 : 2);
    setState(() {}); // refresh para kcal auto
  }

  void _maybeRecalcKcal() {
    if (_autoKcal) {
      final p = _v(_protein);
      final c = _v(_carbs);
      final f = _v(_fat);
      final kcal = 4 * p + 4 * c + 9 * f;
      _kcal.text =
          kcal.toStringAsFixed(kcal.truncateToDouble() == kcal ? 0 : 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    _maybeRecalcKcal(); // mantém kcal em sincronia quando auto estiver ativo

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _f,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.initial == null ? 'Adicionar item' : 'Editar item',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              // Alimento
              TextFormField(
                controller: _food,
                decoration: const InputDecoration(labelText: 'Alimento'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),

              // Quantidade + Unidade
              Row(children: [
                Expanded(
                  child: _NumberWithStepper(
                    label: 'Qtd',
                    controller: _qty,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<String>(
                    value: _unit,
                    items: const [
                      DropdownMenuItem(value: 'g', child: Text('g')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                      DropdownMenuItem(value: 'porção', child: Text('porção')),
                    ],
                    onChanged: (v) => setState(() => _unit = v ?? 'g'),
                    decoration: const InputDecoration(labelText: 'Unid'),
                  ),
                ),
              ]),
              const SizedBox(height: 8),

              // Kcal com auto-cálculo
              SwitchListTile.adaptive(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Calcular kcal automaticamente (4/4/9)'),
                value: _autoKcal,
                onChanged: (v) => setState(() => _autoKcal = v),
              ),
              const SizedBox(height: 4),

              _NumberWithStepper(
                label: 'Kcal',
                controller: _kcal,
                enabled: !_autoKcal, // desativa quando auto
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),

              // Proteínas / Carbo / Gordura
              Row(children: [
                Expanded(
                  child: _NumberWithStepper(
                    label: 'Prot (g)',
                    controller: _protein,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NumberWithStepper(
                    label: 'Carb (g)',
                    controller: _carbs,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: _NumberWithStepper(
                    label: 'Gord (g)',
                    controller: _fat,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                // espaço para futuro campo de fibra/sódio, se quiser
                const SizedBox(width: 0),
              ]),

              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                    onPressed: () {
                      if (!_f.currentState!.validate()) return;
                      // kcal final (se auto, já está calculado)
                      final item = MealItem(
                        food: _food.text.trim(),
                        quantity: _v(_qty),
                        unit: _unit,
                        kcal: _v(_kcal),
                        protein: _v(_protein),
                        carbs: _v(_carbs),
                        fat: _v(_fat),
                      );
                      Navigator.pop(context, item);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- widget auxiliar: número com stepper ----------------------
class _NumberWithStepper extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const _NumberWithStepper({
    required this.label,
    required this.controller,
    this.enabled = true,
    this.onChanged,
  });

  double _v() => double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            enabled: enabled,
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: label),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: enabled
                    ? () {
                        final v = _v() - 1;
                        controller.text = (v < 0 ? 0 : v)
                            .toStringAsFixed((v % 1 == 0) ? 0 : 2);
                        onChanged?.call(controller.text);
                      }
                    : null,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: enabled
                    ? () {
                        final v = _v() + 1;
                        controller.text =
                            v.toStringAsFixed((v % 1 == 0) ? 0 : 2);
                        onChanged?.call(controller.text);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
