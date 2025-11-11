import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/onboarding_provider.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth_gate.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _iniciarOnboarding(BuildContext context) async {
    try {
      // Verifica se já há um usuário logado
      User? user = FirebaseAuth.instance.currentUser;

      // Caso não haja, cria um usuário anônimo
      user ??= (await FirebaseAuth.instance.signInAnonymously()).user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao iniciar sessão. Tente novamente.'),
          ),
        );
        return;
      }

      // Envia para o onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => OnboardingProvider(user?.uid ?? ''),
            child: const OnboardingScreen(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // --- IMAGEM DE CAPA ---
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/welcome_food.png',
                  height: size.height * 0.3,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 48),

              // --- TÍTULO ---
              const Text(
                'Seu plano começa aqui 🍎',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // --- DESCRIÇÃO ---
              const Text(
                'Responda algumas perguntas rápidas e receba um plano alimentar personalizado de acordo com seus objetivos e rotina!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),

              // --- BOTÃO COMEÇAR ---
              ElevatedButton(
                onPressed: () => _iniciarOnboarding(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Começar'),
              ),
              const SizedBox(height: 16),

              // --- BOTÃO JÁ TENHO CONTA ---
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Já tenho uma conta'),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
