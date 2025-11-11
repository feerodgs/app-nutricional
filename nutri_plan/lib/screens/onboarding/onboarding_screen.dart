import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/onboarding_provider.dart';
import '../../models/pessoa.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Lista com as perguntas
  final List<String> _perguntas = [
    "Qual é o seu nome completo?",
    "Qual é a sua idade?",
    "Qual é o seu gênero?",
    "Qual é a sua altura (cm)?",
    "Qual é o seu peso atual (kg)?",
    "Qual é o seu peso desejado (kg)?",
    "Qual é o seu objetivo principal?",
    "Em quanto tempo quer alcançar esse objetivo?",
    "Quão comprometido(a) você está? (1 a 5)",
    "Como é sua rotina de atividade física?",
    "Que tipo de atividades pratica?",
    "Quantas horas dorme por noite?",
    "Nível de estresse atual?",
    "Quantas refeições principais faz por dia?",
    "Costuma pular alguma refeição?",
    "Quantas vezes por semana come fora?",
    "Consome bebidas alcoólicas?",
    "Consome refrigerantes/sucos industrializados?",
    "Quantos litros de água bebe por dia?",
    "Tem restrições alimentares?",
    "Tem condições de saúde relevantes?",
    "Usa medicamentos contínuos?",
    "Quais alimentos prefere?",
    "Quais alimentos não gosta?",
    "Segue algum estilo alimentar?",
    "Já tentou fazer dieta antes? Qual?",
    "Por que desistiu da última vez?",
    "Quais suas maiores dificuldades?",
    "O que te motiva a mudar agora?",
    "Quer receber lembretes diários?",
    "Quer ver substituições inteligentes?",
    "Quer acompanhar progresso com fotos?",
    "Deseja revisar as respostas antes de salvar?",
    "Confirma suas informações?"
  ];

  // Armazena respostas temporárias
  final Map<int, String> _respostas = {};

  void _proximaPergunta() {
    if (_currentPage < _perguntas.length - 1) {
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finalizarCadastro();
    }
  }

  void _anteriorPergunta() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finalizarCadastro() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final pessoa = provider.pessoa;

    // Exemplo: salvar apenas o nome e objetivo (você pode adaptar)
    provider.updateNome(_respostas[0] ?? '');
    provider.updateObjetivo(ObjetivoPrincipal.reeducacao);
    provider.updateMetaEspecifica(_respostas[6] ?? '');

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(pessoa.uid)
          .set(pessoa.toMap(), SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil criado com sucesso!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pergunta = _perguntas[_currentPage];
    final controller = TextEditingController(text: _respostas[_currentPage]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pergunta ${_currentPage + 1}/${_perguntas.length}'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _perguntas.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _perguntas[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  onChanged: (value) => _respostas[index] = value,
                  decoration: InputDecoration(
                    hintText: "Digite sua resposta aqui...",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (index > 0)
                      ElevatedButton(
                        onPressed: _anteriorPergunta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        child: const Text('Voltar'),
                      ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _proximaPergunta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: Text(index == _perguntas.length - 1
                          ? 'Finalizar'
                          : 'Próximo'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
