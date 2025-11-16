import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'sign_up_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});
  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail')),
            const SizedBox(height: 8),
            TextField(
                controller: _pass,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true),
            const SizedBox(height: 16),
            if (vm.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child:
                    Text(vm.error!, style: const TextStyle(color: Colors.red)),
              ),
            FilledButton(
              onPressed: vm.loading
                  ? null
                  : () async {
                      await context.read<AuthViewModel>().signInWithEmail(
                            _email.text,
                            _pass.text,
                          );
                      // Root (authState) faz a troca de tela.
                    },
              child: vm.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Entrar'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: vm.loading
                  ? null
                  : () async {
                      final cur = FirebaseAuth.instance.currentUser;
                      if (cur != null) {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Você já está logado'),
                            content: Text(
                                'Conta atual: ${cur.email ?? cur.uid}\n\nDeseja sair para criar uma nova conta?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar')),
                              FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sair')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await context.read<AuthViewModel>().signOut();
                          if (!context.mounted) return;
                        } else {
                          return;
                        }
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SignUpView()));
                    },
              child: const Text('Primeiro acesso? Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}
