import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/app_user.dart';
import '../data/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  AppUser? user;
  bool loading = false;
  String? error;

  StreamSubscription<AppUser?>? _sub;

  Future<void> loadUser() async {
    await loadCurrent();
  }

  Future<void> loadCurrent() async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;

    if (fbUser == null) {
      user = null;
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    _sub?.cancel();

    _sub = UserRepository.watchById(fbUser.uid).listen((u) {
      user = u;
      loading = false;
      notifyListeners();
    }, onError: (_) {
      error = 'Erro ao carregar usuário';
      loading = false;
      notifyListeners();
    });
  }

  Future<void> updateName(String name) async {
    if (user == null) return;
    loading = true;
    notifyListeners();

    try {
      final u = user!.copyWith(name: name);
      await UserRepository.updateProfile(u);
      user = u;
    } catch (_) {
      error = 'Erro ao atualizar perfil';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? email}) async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      error = 'Sem usuário autenticado';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final updated = (user ?? AppUser(uid: fbUser.uid))
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
    } catch (_) {
      error = 'Erro ao atualizar perfil';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
