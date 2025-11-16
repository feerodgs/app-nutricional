import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthStatus { idle, loading }

class AuthViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  AuthStatus status = AuthStatus.idle;
  String? error;

  Stream<User?> get authState => _auth.authStateChanges();
  bool get loading => status == AuthStatus.loading;

  Future<void> signInWithEmail(String email, String password) async {
    if (status == AuthStatus.loading) return;
    status = AuthStatus.loading;
    error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
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

      await _db.collection('users').doc(u.uid).set({
        'uid': u.uid,
        'name': (name ?? '').trim(),
        'email': u.email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      error = _map(e); // mapeia email-already-in-use, weak-password, etc.
    } catch (_) {
      error = 'Falha inesperada no cadastro';
    } finally {
      status = AuthStatus.idle;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (status == AuthStatus.loading) return;
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
        return 'Senha fraca (mín. 6 caracteres)';
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
