import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- ALTERAÇÃO AQUI ---
// 1. Remova a importação da antiga tela de login.
// import 'login_screen.dart';
// 2. Importe a nova tela de autenticação com os botões sociais.
import 'auth_screen.dart';

import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Escuta as mudanças no estado de autenticação (login/logout)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mostra um indicador de carregamento enquanto o Firebase verifica o estado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se há um usuário logado (snapshot.hasData ou snapshot.data != null)
        if (snapshot.hasData) {
          // Retorna a tela principal (HomeScreen)
          return const HomeScreen();
        }
        // Se não houver usuário logado (snapshot.data == null)
        else {
          // --- ALTERAÇÃO AQUI ---
          // Retorna a nova tela de autenticação com login social
          return const AuthScreen();
        }
      },
    );
  }
}
