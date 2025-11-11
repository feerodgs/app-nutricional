import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';
import '../data/user_repository.dart';

enum AuthStatus { idle, loading, error, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  AuthStatus status = AuthStatus.idle;
  String? errorMessage;

  Stream<fb.User?> get authState => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    _set(AuthStatus.loading);
    try {
      final cred =
          await AuthService.signInWithEmail(email: email, password: password);
      await UserRepository.ensureUserDocument(cred.user!);
      _set(AuthStatus.authenticated);
    } catch (e) {
      errorMessage = 'Falha no login';
      _set(AuthStatus.error);
    }
  }

  Future<void> signUp(String email, String password, {String? name}) async {
    _set(AuthStatus.loading);
    try {
      final cred = await AuthService.signUpWithEmail(
        email: email,
        password: password,
        displayName: name,
      );
      await UserRepository.ensureUserDocument(cred.user!);
      _set(AuthStatus.authenticated);
    } catch (e) {
      errorMessage = 'Falha no cadastro';
      _set(AuthStatus.error);
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    _set(AuthStatus.unauthenticated);
  }

  void _set(AuthStatus s) {
    status = s;
    notifyListeners();
  }
}
