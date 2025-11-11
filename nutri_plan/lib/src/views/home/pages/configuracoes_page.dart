import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
// opcional: import da tela de metas

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final u = userVM.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Configurações', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(_initials(u?.name, u?.email))),
            title: Text(u?.name ?? 'Usuário'),
            subtitle: Text(u?.email ?? '-'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {/* TODO: perfil detalhado */},
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Metas do dia'),
            subtitle: const Text('Calorias e macros'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {/* TODO: Navigator.push para EditGoalsView */},
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
