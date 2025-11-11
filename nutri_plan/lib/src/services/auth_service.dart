import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await cred.user!.updateDisplayName(displayName.trim());
    }
    return cred;
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> updateDisplayName(String name) async {
    final u = _auth.currentUser;
    if (u != null) await u.updateDisplayName(name.trim());
  }

  static Future<void> reload() async => _auth.currentUser?.reload();

  static Future<void> signOut() => _auth.signOut();

  // Opcional: deleção definitiva do usuário autenticado.
  static Future<void> deleteCurrentUser() async {
    final u = _auth.currentUser;
    if (u != null) await u.delete();
  }
}
