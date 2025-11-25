import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/app_user.dart';
import '../data/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  AppUser? user;
  bool loading = false;
  String? error;

  Stream<AppUser?>? _sub;
  StreamSubscription<AppUser?>? _listener;

  Future<void> loadCurrent() async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;

    if (fbUser == null) {
      user = null;
      error = null;
      notifyListeners();
      return;
    }

    loading = true;
    error = null; // LIMPA ERRO ANTIGO !!!
    notifyListeners();

    // Cancela listener anterior
    await _listener?.cancel();

    try {
      _listener = UserRepository.watchById(fbUser.uid).listen(
        (u) {
          user = u;

          // se o doc não existir ainda, não é erro
          if (u == null) {
            error = null;
          }

          loading = false;
          notifyListeners();
        },
        onError: (e) {
          error = "Erro ao carregar usuário";
          loading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      loading = false;
      error = "Erro ao carregar usuário";
      notifyListeners();
    }
  }

  // -------------------------------------------
  // Update profile
  // -------------------------------------------
  Future<void> updateProfile({String? name, String? email}) async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;

    if (fbUser == null) {
      error = "Sem usuário autenticado";
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final updated =
          (user ?? AppUser(uid: fbUser.uid, name: null, email: null))
              .copyWith(name: name ?? user?.name, email: email ?? user?.email);

      await UserRepository.updateProfile(updated);
      user = updated;

      if (name != null && name.trim().isNotEmpty) {
        await fbUser.updateDisplayName(name.trim());
      }

      if (email != null &&
          email.trim().isNotEmpty &&
          email.trim() != fbUser.email) {
        await fbUser.verifyBeforeUpdateEmail(email.trim());
      }
    } catch (e) {
      error = "Erro ao atualizar perfil";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> dispose() async {
    await _listener?.cancel();
    super.dispose();
  }
}
