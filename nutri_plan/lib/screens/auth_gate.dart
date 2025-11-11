import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'onboarding/onboarding_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _hasUserProfile(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Estado de verificação inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Usuário logado
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          // Usa FutureBuilder pra verificar se o perfil Pessoa existe
          return FutureBuilder<bool>(
            future: _hasUserProfile(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Se o perfil já existe → vai pra HomeScreen
              if (profileSnapshot.data == true) {
                return const HomeScreen();
              }

              // Se o perfil NÃO existe → inicia o Onboarding
              return ChangeNotifierProvider(
                create: (_) => OnboardingProvider(user.uid),
                child: const OnboardingScreen(),
              );
            },
          );
        }

        // Nenhum usuário logado → vai pra tela de autenticação
        return const AuthScreen();
      },
    );
  }
}
