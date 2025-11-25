import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/onboarding_viewmodel.dart';
import 'screens/onboarding_step_age_screen.dart';

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: const _OnboardingNavigator(),
    );
  }
}

class _OnboardingNavigator extends StatefulWidget {
  const _OnboardingNavigator();

  @override
  State<_OnboardingNavigator> createState() => _OnboardingNavigatorState();
}

class _OnboardingNavigatorState extends State<_OnboardingNavigator> {
  final navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const OnboardingStepAgeView(),
        );
      },
    );
  }
}
