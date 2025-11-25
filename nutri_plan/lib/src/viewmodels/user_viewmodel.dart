import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/app_user.dart';
import '../data/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  AppUser? user;
  bool loading = false;
  String? error;

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
    try {
      user = await UserRepository.getById(fbUser.uid);
    } catch (e) {
      error = 'Erro ao carregar usuário';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateName(String name) async {
    if (user == null) return;
    loading = true;
    notifyListeners();
    try {
      final u = user!.copyWith(name: name);
      await UserRepository.updateProfile(u);
      user = u;
    } catch (e) {
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
      error = 'Erro ao atualizar perfil';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
