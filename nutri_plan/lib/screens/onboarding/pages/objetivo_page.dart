import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profile_model.dart';
import '../../../providers/onboarding_provider.dart';

class ObjetivoPage extends StatelessWidget {
  const ObjetivoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessa o nosso provedor de dados
    final onboardingProvider = Provider.of<OnboardingProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qual o seu objetivo?',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          // Usamos o 'objetivo' do provedor para saber qual item está selecionado
          _buildOptionCard(
            context,
            icon: Icons.scale,
            title: 'Emagrecer',
            subtitle: 'Perder peso de forma saudável',
            isSelected: onboardingProvider.objetivo == Objetivo.emagrecer,
            onTap: () => onboardingProvider.updateObjetivo(Objetivo.emagrecer),
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            icon: Icons.fitness_center,
            title: 'Ganhar peso',
            subtitle: 'Aumentar a massa muscular',
            isSelected: onboardingProvider.objetivo == Objetivo.ganharPeso,
            onTap: () => onboardingProvider.updateObjetivo(Objetivo.ganharPeso),
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            icon: Icons.apple,
            title: 'Manter peso',
            subtitle: 'Manter peso com saúde',
            isSelected: onboardingProvider.objetivo == Objetivo.manterPeso,
            onTap: () => onboardingProvider.updateObjetivo(Objetivo.manterPeso),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar os cards de opção
  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue, size: 30),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
