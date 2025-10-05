import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profile_model.dart';
import '../../../providers/onboarding_provider.dart';

class SexoPage extends StatelessWidget {
  const SexoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qual o seu sexo?',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildOptionCard(
            context,
            title: 'Feminino',
            isSelected: onboardingProvider.sexo == Sexo.feminino,
            onTap: () => onboardingProvider.updateSexo(Sexo.feminino),
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            title: 'Masculino',
            isSelected: onboardingProvider.sexo == Sexo.masculino,
            onTap: () => onboardingProvider.updateSexo(Sexo.masculino),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // (Estilização similar à da tela anterior)
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Row(
            children: [
              // Placeholder para o ícone
              const SizedBox(width: 46),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
