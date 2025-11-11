import 'package:flutter/material.dart';
import '../models/pessoa.dart';

class OnboardingProvider with ChangeNotifier {
  Pessoa _pessoa;

  // Construtor inicial: cria a pessoa com UID (obtido após login no Firebase Auth)
  OnboardingProvider(String uid) : _pessoa = Pessoa(uid: uid);

  Pessoa get pessoa => _pessoa;

  /// ===== MÉTODOS DE ATUALIZAÇÃO =====

  void updateNome(String nome) {
    _pessoa = _pessoa.copyWith(nome: nome);
    notifyListeners();
  }

  void updateGenero(Genero genero) {
    _pessoa = _pessoa.copyWith(genero: genero);
    notifyListeners();
  }

  void updateAltura(double alturaCm) {
    _pessoa = _pessoa.copyWith(alturaCm: alturaCm);
    notifyListeners();
  }

  void updatePeso(double pesoKg) {
    _pessoa = _pessoa.copyWith(pesoKg: pesoKg);
    notifyListeners();
  }

  void updateObjetivo(ObjetivoPrincipal objetivo) {
    _pessoa = _pessoa.copyWith(objetivoPrincipal: objetivo);
    notifyListeners();
  }

  void updateNivelAtividade(NivelAtividade nivel) {
    _pessoa = _pessoa.copyWith(nivelAtividade: nivel);
    notifyListeners();
  }

  void updateMetaEspecifica(String meta) {
    _pessoa = _pessoa.copyWith(metaEspecifica: meta);
    notifyListeners();
  }

  void updateComprometimento(int valor) {
    _pessoa = _pessoa.copyWith(comprometimento: valor);
    notifyListeners();
  }

  void updatePreferencias(List<String> preferencias) {
    _pessoa = _pessoa.copyWith(preferencias: preferencias);
    notifyListeners();
  }

  void updateEstiloPlano(EstiloPlano estilo) {
    _pessoa = _pessoa.copyWith(estiloPlano: estilo);
    notifyListeners();
  }

  /// ===== RESETAR / FINALIZAR =====

  void resetPessoa(String uid) {
    _pessoa = Pessoa(uid: uid);
    notifyListeners();
  }

  /// Esse método pode ser chamado no final do onboarding
  /// para salvar no Firestore via DataService
  Future<void> salvarPessoa(Function(Pessoa pessoa) salvarNoFirestore) async {
    await salvarNoFirestore(_pessoa);
  }
}
