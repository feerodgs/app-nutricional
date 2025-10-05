import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';

class OnboardingProvider with ChangeNotifier {
  Objetivo? _objetivo;
  Sexo? _sexo;
  // ... outros campos virão aqui no futuro

  Objetivo? get objetivo => _objetivo;
  Sexo? get sexo => _sexo;

  void updateObjetivo(Objetivo novoObjetivo) {
    _objetivo = novoObjetivo;
    notifyListeners(); // Avisa a UI que um dado mudou
  }

  void updateSexo(Sexo novoSexo) {
    _sexo = novoSexo;
    notifyListeners();
  }
}
