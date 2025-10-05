import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // <-- 1. IMPORTAMOS O AUTHSERVICE

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. CRIAMOS UMA INSTÂNCIA DO NOSSO SERVIÇO
    final authService = AuthService();

    final userEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'Usuário Desconhecido';

    final backgroundGray = const Color(0xFFF5F5F5);
    final mainBlue = const Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text(
          'NutriPlan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Sair',
            onPressed: () async {
              // 3. AGORA CHAMAMOS O MÉTODO DO NOSSO SERVIÇO
              await authService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: mainBlue.withOpacity(0.1),
                    child: Icon(Icons.local_dining, size: 40, color: mainBlue),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Bem-vindo ao NutriPlan!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Logado como: $userEmail",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildFeatureCard(
                  icon: Icons.restaurant_menu,
                  title: "Registrar Refeição",
                  color: mainBlue,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  icon: Icons.list_alt,
                  title: "Plano Alimentar",
                  color: mainBlue,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  icon: Icons.show_chart,
                  title: "Meu Progresso",
                  color: mainBlue,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  icon: Icons.tips_and_updates,
                  title: "Dicas de Nutrição",
                  color: mainBlue,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget de card (continua o mesmo)
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    // ... seu código do card ...
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 30,
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
