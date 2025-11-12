import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../settings/edit_goals_view.dart'; // ajuste o import se necessário

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadCurrent(); // <- AQUI
    });
  }

  String _initials(String? name, String? email) {
    final base = (name?.trim().isNotEmpty == true ? name! : (email ?? ''))
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (base.isEmpty) return 'US';
    final parts = base.split(' ');
    final first = parts.first.characters.first.toUpperCase();
    final last =
        parts.length > 1 ? parts.last.characters.first.toUpperCase() : '';
    return '$first$last';
  }

  Future<void> _editUserSheet(BuildContext context) async {
    final vm = context.read<UserViewModel>();
    final authUser = FirebaseAuth.instance.currentUser;

    final currentName = vm.user?.name?.trim().isNotEmpty == true
        ? vm.user!.name!
        : (authUser?.displayName ?? '');
    final currentEmail = vm.user?.email?.trim().isNotEmpty == true
        ? vm.user!.email!
        : (authUser?.email ?? '');

    final nameCtrl = TextEditingController(text: currentName);
    final emailCtrl = TextEditingController(text: currentEmail);
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding:
              EdgeInsets.only(bottom: viewInsets.bottom), // sobe com teclado
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false, // não ocupa a tela toda; respeita o padding animado
            builder: (ctx, scroll) {
              return SingleChildScrollView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 4,
                        width: 48,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text('Editar cadastro',
                          style: Theme.of(ctx).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe o nome'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return 'Informe o e-mail';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(t)) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => FocusScope.of(ctx).unfocus(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              try {
                                await vm.updateProfile(
                                  name: nameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                );
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cadastro atualizado.'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Erro ao salvar: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final authUser = FirebaseAuth.instance.currentUser;

    final displayName = (userVM.user?.name?.trim().isNotEmpty == true)
        ? userVM.user!.name!
        : (authUser?.displayName ?? 'Usuário');
    final displayEmail = (userVM.user?.email?.trim().isNotEmpty == true)
        ? userVM.user!.email!
        : (authUser?.email ?? '-');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Configurações', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading:
                CircleAvatar(child: Text(_initials(displayName, displayEmail))),
            title: Text(displayName),
            subtitle: Text(displayEmail),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editUserSheet(context),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Metas do dia'),
            subtitle: const Text('Calorias e macros'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditGoalsView()),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () => context.read<AuthViewModel>().signOut(),
          ),
        ),
        if (userVM.loading)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (userVM.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                Text(userVM.error!, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
}
