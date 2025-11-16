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
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v != null && v.contains('@'))
                        ? null
                        : 'E-mail inválido',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _pass,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    validator: (v) => (v != null && v.length >= 6)
                        ? null
                        : 'Mín. 6 caracteres',
                  ),
                  const SizedBox(height: 12),

                  if (vm.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(vm.error!,
                          style: const TextStyle(color: Colors.red)),
                    ),

                  // ---- Botão principal (ElevatedButton) ----
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: vm.loading
                          ? null
                          : () async {
                              if (!_f.currentState!.validate()) return;

                              await context.read<AuthViewModel>().signUp(
                                    _email.text,
                                    _pass.text,
                                    name: _name.text,
                                  );

                              if (!mounted) return;

                              final err = context.read<AuthViewModel>().error;
                              if (err != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                                return; // não fecha a tela em erro
                              }

                              // sucesso: volta para o login; Root trocará para Home se já logado
                              Navigator.pop(context);
                            },
                      child: vm.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Criar conta'),
                    ),
                  ),

                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: vm.loading ? null : () => Navigator.pop(context),
                    child: const Text('Já tenho conta? Entrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
