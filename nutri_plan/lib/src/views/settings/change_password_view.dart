import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;

  Future<void> _change() async {
    FocusScope.of(context).unfocus();

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário não autenticado.")),
      );
      return;
    }

    if (_new.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas novas não coincidem.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Reautenticação obrigatória
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _current.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      // Troca a senha
      await user.updatePassword(_new.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha alterada com sucesso!")),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Erro ao alterar senha.";
      if (e.code == 'wrong-password') msg = "Senha atual incorreta.";
      if (e.code == 'weak-password') msg = "Senha nova muito fraca.";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro inesperado: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alterar senha")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _current,
            decoration: const InputDecoration(labelText: "Senha atual"),
            obscureText: true,
          ),
          TextField(
            controller: _new,
            decoration: const InputDecoration(labelText: "Nova senha"),
            obscureText: true,
          ),
          TextField(
            controller: _confirm,
            decoration:
                const InputDecoration(labelText: "Confirmar nova senha"),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _change,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Salvar nova senha"),
          ),
        ],
      ),
    );
  }
}
