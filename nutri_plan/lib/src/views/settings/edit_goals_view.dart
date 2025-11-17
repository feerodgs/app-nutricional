import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/settings_repository.dart';
import '../../models/user_goals.dart';
import '../home/home_view.dart';

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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadGoalsWithRetry();
  }

  @override
  void dispose() {
    _kcal.dispose();
    _prot.dispose();
    _carb.dispose();
    _fat.dispose();
    super.dispose();
  }

  Future<void> _loadGoalsWithRetry() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      final g = await SettingsRepository.getGoals(uid);
      _fill(g);
      if (mounted) setState(() => _loading = false);
    } on FirebaseException catch (e) {
      // offline/instável -> retry simples
      if (e.code == 'unavailable') {
        await Future.delayed(const Duration(milliseconds: 800));
        try {
          final g2 = await SettingsRepository.getGoals(uid);
          _fill(g2);
        } catch (_) {
          _fill(UserGoals.defaults);
          if (mounted) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Rede instável. Usando metas padrão.'),
            ));
          }
          return;
        }
        if (mounted) setState(() => _loading = false);
      } else {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao carregar metas: ${e.code}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar metas: $e')),
      );
    }
  }

  void _fill(UserGoals g) {
    _kcal.text = g.kcal.toStringAsFixed(0);
    _prot.text = g.protein.toStringAsFixed(0);
    _carb.text = g.carbs.toStringAsFixed(0);
    _fat.text = g.fat.toStringAsFixed(0);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final g = UserGoals(
        kcal: double.tryParse(_kcal.text.replaceAll(',', '.')) ?? 0,
        protein: double.tryParse(_prot.text.replaceAll(',', '.')) ?? 0,
        carbs: double.tryParse(_carb.text.replaceAll(',', '.')) ?? 0,
        fat: double.tryParse(_fat.text.replaceAll(',', '.')) ?? 0,
      );
      await SettingsRepository.saveGoals(uid, g);

      if (!mounted) return;

      // Vai para a Home (aba 0), limpando a pilha
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeView(
            initialIndex: 0,
            key: ValueKey('home-index-0'),
          ),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar metas: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
    );
  }

  Widget _numField(TextEditingController c, String label) => TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      );
}
