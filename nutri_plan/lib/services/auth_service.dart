import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_profile_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FUNÇÃO ATUALIZADA PARA USAR O USERPROFILE MODEL ---
  Future<void> _syncUserData(UserCredential userCredential) async {
    final User? user = userCredential.user;
    if (user == null) return;

    final userDocRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDocRef.get();

    if (!docSnapshot.exists) {
      // 1. Criamos uma instância do seu modelo
      final newUserProfile = UserProfile(
        userId: user.uid,
        email: user.email ?? '', // Usamos ?? '' para garantir que não seja nulo
        nome: user.displayName,
        photoUrl: user.photoURL,
        // O campo 'createdAt' será preenchido pelo servidor do Firestore
      );

      // 2. Usamos o método .toFirestore() para converter o objeto em um mapa
      await userDocRef.set(newUserProfile.toFirestore());
    }
  }

  // (O resto dos métodos de login continuam exatamente os mesmos)

  // MÉTODO DE LOGIN COM GOOGLE
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await _syncUserData(userCredential);
      return userCredential.user;
    } catch (e) {
      print("Erro no login com Google: $e");
      return null;
    }
  }

  // MÉTODO DE LOGIN COM FACEBOOK
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        await _syncUserData(userCredential);
        return userCredential.user;
      }
      return null;
    } catch (e) {
      print("Erro no login com Facebook: $e");
      return null;
    }
  }

  // Método para deslogar
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    // await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }
}
