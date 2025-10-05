import 'package:flutter/material.dart';
import 'pages/objetivo_page.dart';
import 'pages/sexo_page.dart';
import 'pages/registration_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  // --- NOME DO TIPO ALTERADO AQUI (SEM UNDERSCORE) ---
  final GlobalKey<RegistrationPageState> _registrationPageKey =
      GlobalKey<RegistrationPageState>();

  late final List<Widget> _pages;

  double _progress = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inicializa a lista de páginas aqui
    _pages = [
      const ObjetivoPage(),
      const SexoPage(),
      // Passa a chave para a RegistrationPage
      RegistrationPage(key: _registrationPageKey),
    ];

    _progress = 1 / _pages.length;

    _pageController.addListener(() {
      setState(() {
        if (_pageController.hasClients && _pageController.page != null) {
          _progress = (_pageController.page! + 1) / _pages.length;
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleFinalStep() async {
    setState(() => _isLoading = true);
    await _registrationPageKey.currentState?.createAccountAndNavigate();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLastPage = _pageController.hasClients &&
        _pageController.page?.round() == _pages.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (_pageController.page == 0) {
              Navigator.of(context).pop();
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (!isLastPage) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _handleFinalStep();
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
              : Text(isLastPage ? 'Criar Conta e Entrar' : 'Continuar'),
        ),
      ),
    );
  }
}
