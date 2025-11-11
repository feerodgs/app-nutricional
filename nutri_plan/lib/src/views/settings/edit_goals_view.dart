import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/settings_repository.dart';
import '../../models/user_goals.dart';

class EditGoalsView extends StatefulWidget {
  const EditGoalsView({super.key});
  @override
  State<EditGoalsView> createState() => _EditGoalsViewState();
}

class _EditGoalsViewState extends State<EditGoalsView> {
  final _kcal = TextEditingController();
  final _prot = TextEditingController();
  final _carb = TextEditingController();
  final _fat = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    SettingsRepository.getGoals(uid).then((g) {
      _kcal.text = g.kcal.toStringAsFixed(0);
      _prot.text = g.protein.toStringAsFixed(0);
      _carb.text = g.carbs.toStringAsFixed(0);
      _fat.text = g.fat.toStringAsFixed(0);
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas do dia')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _numField(_kcal, 'Calorias (kcal)'),
                _numField(_prot, 'Proteína (g)'),
                _numField(_carb, 'Carboidratos (g)'),
                _numField(_fat, 'Gorduras (g)'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    final g = UserGoals(
                      kcal: double.tryParse(_kcal.text) ?? 0,
                      protein: double.tryParse(_prot.text) ?? 0,
                      carbs: double.tryParse(_carb.text) ?? 0,
                      fat: double.tryParse(_fat.text) ?? 0,
                    );
                    await SettingsRepository.saveGoals(uid, g);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
    );
  }

  Widget _numField(TextEditingController c, String label) => TextField(
      controller: c,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number);
}
