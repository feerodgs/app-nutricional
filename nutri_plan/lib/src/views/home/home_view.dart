import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_plan/src/services/daily_meal_service.dart';

import 'pages/menu_inicial_page.dart';
import 'pages/refeicoes_page.dart';
import 'pages/historico_page.dart';
import 'pages/configuracoes_page.dart';

class HomeView extends StatefulWidget {
  final int initialIndex;
  const HomeView({super.key, this.initialIndex = 0});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late int _index;
  bool _generated = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _generateMealsOnce();
  }

  Future<void> _generateMealsOnce() async {
    if (_generated) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await DailyMealService.generateIfEmpty(user.uid);

    _generated = true;
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      MenuInicialPage(),
      RefeicoesPage(),
      HistoricoPage(),
      ConfiguracoesPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Refeições',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_toggle_off),
            selectedIcon: Icon(Icons.history),
            label: 'Hist.',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Conf.',
          ),
        ],
      ),
    );
  }
}
