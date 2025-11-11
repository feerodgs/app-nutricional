// src/views/auth/sign_up_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});
  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _f = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _f,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nome')),
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
                vm.status == AuthStatus.loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_f.currentState!.validate()) {
                            context.read<AuthViewModel>().signUp(
                                _email.text, _pass.text,
                                name: _name.text);
                            Navigator.pop(context);
                          }
                        },
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
