import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Importa a tela de login
import 'main.dart'; // Importa o MyHomePage

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
          // Retorna a tela principal (MyHomePage, neste caso)
          return const MyHomePage();
        }
        // Se não houver usuário logado (snapshot.data == null)
        else {
          // Retorna a tela de login/cadastro
          return const LoginScreen();
        }
      },
    );
  }
}
