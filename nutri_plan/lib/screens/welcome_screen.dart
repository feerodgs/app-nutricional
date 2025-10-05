// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. IMPORTAMOS O PROVIDER AQUI
import '../providers/onboarding_provider.dart'; // <-- E O NOSSO ONBOARDINGPROVIDER
import 'auth_gate.dart';
import 'onboarding/onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              // (Toda a sua UI continua a mesma...)
              const Spacer(flex: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset('assets/welcome_food.png',
                    height: size.height * 0.3, fit: BoxFit.cover),
              ),
              const SizedBox(height: 48),
              const Text('Receitas saudáveis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 16),
              const Text(
                'Escolha entre dezenas de receitas para incluir na sua dieta, com instruções passo a passo. Nunca foi tão fácil seguir o seu plano alimentar personalizado!',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
              const Spacer(flex: 3),

              // Botão "Começar"
              ElevatedButton(
                onPressed: () {
                  // --- 2. A MÁGICA ACONTECE AQUI ---
                  // Agora, nós criamos um OnboardingProvider NOVO e o disponibilizamos
                  // apenas para a OnboardingScreen e suas telas filhas.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => OnboardingProvider(),
                        child: const OnboardingScreen(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Começar'),
              ),
              const SizedBox(height: 16),

              // Botão "Já tenho uma conta"
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
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
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
