import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/user_repository.dart';

enum AuthStatus { idle, loading }

class AuthViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;

  AuthStatus status = AuthStatus.idle;
  String? error;

  Stream<User?> get authState => _auth.authStateChanges();
  bool get loading => status == AuthStatus.loading;

  Future<void> signInWithEmail(String email, String password) async {
    if (loading) return;

    status = AuthStatus.loading;
    error = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await UserRepository.ensureUserDocument(cred.user!);
    } on FirebaseAuthException catch (e) {
      error = _map(e);
    } catch (_) {
      error = 'Falha inesperada no login';
    } finally {
      status = AuthStatus.idle;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, {String? name}) async {
    if (loading) return;

    status = AuthStatus.loading;
    error = null;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final u = cred.user;
      if (u == null) throw FirebaseAuthException(code: 'user-null');

      if ((name ?? '').trim().isNotEmpty) {
        await u.updateDisplayName(name!.trim());
      }

      await UserRepository.ensureUserDocument(u);

      await UserRepository.updateFields(u.uid, {
        'name': name ?? '',
        'email': u.email,
        'finishedOnboarding': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      error = _map(e);
    } catch (_) {
      error = 'Falha inesperada no cadastro';
    } finally {
      status = AuthStatus.idle;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (loading) return;

    status = AuthStatus.loading;
    error = null;
    notifyListeners();

    try {
      await _auth.signOut();
    } catch (_) {
      error = 'Falha ao sair';
    } finally {
      status = AuthStatus.idle;
      notifyListeners();
    }
  }

  String _map(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido';
      case 'email-already-in-use':
        return 'E-mail já cadastrado';
      case 'weak-password':
        return 'Senha fraca (mínimo 6 caracteres)';
      case 'user-disabled':
        return 'Usuário desativado';
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde.';
      default:
        return 'Erro de autenticação: ${e.code}';
    }
  }
}
