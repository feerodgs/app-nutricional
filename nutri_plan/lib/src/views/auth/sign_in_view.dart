// src/views/auth/sign_in_view.dart
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
  final _f = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _f,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'E-mail inválido',
                ),
                TextFormField(
                  controller: _pass,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Mín. 6',
                ),
                const SizedBox(height: 12),
                if (vm.status == AuthStatus.error)
                  Text(vm.errorMessage ?? 'Erro',
                      style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                vm.status == AuthStatus.loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_f.currentState!.validate()) {
                            context
                                .read<AuthViewModel>()
                                .signIn(_email.text, _pass.text);
                          }
                        },
                        child: const Text('Entrar'),
                      ),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SignUpView())),
                  child: const Text('Criar conta'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
