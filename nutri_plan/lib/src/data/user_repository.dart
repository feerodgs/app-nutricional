import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/app_user.dart';

class UserRepository {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users');

  static DocumentReference<Map<String, dynamic>> docRef(String uid) =>
      _col.doc(uid);

  /// Cria/atualiza o documento do usuário autenticado.
  static Future<void> ensureUserDocument(fb.User fbUser) async {
    final ref = docRef(fbUser.uid);
    final snap = await ref.get();
    final now = DateTime.now();

    if (!snap.exists) {
      final appUser = AppUser(
        uid: fbUser.uid,
        email: fbUser.email,
        name: fbUser.displayName,
        lastUpdated: now,
      );
      await ref.set(appUser.toJson(), SetOptions(merge: true));
    } else {
      await ref.set({'lastUpdated': now}, SetOptions(merge: true));
    }
  }

  static Future<bool> exists(String uid) async {
    final snap = await docRef(uid).get();
    return snap.exists;
  }

  static Future<AppUser?> getById(String uid) async {
    final snap = await docRef(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return AppUser.fromJson(data);
  }

  static Stream<AppUser?> watchById(String uid) {
    return docRef(uid).snapshots().map((snap) {
      final data = snap.data();
      return data == null ? null : AppUser.fromJson(data);
    });
  }

  static Future<void> upsert(AppUser user) async {
    await docRef(user.uid).set(user.toJson(), SetOptions(merge: true));
  }

  static Future<void> updateProfile(AppUser user) => upsert(user);

  static Future<void> updateFields(
      String uid, Map<String, dynamic> data) async {
    data['lastUpdated'] = DateTime.now();
    await docRef(uid).set(data, SetOptions(merge: true));
  }

  // Opcional: evitar deletes de conta por segurança/regra.
  static Future<void> softDelete(String uid) async {
    await updateFields(uid, {'active': false});
  }
}
