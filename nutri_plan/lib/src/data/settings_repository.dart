import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_goals.dart';

class SettingsRepository {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('settings').doc('goals');

  /// Stream reativa (funciona com cache offline). Se o doc não existir,
  /// emite `UserGoals.defaults`.
  static Stream<UserGoals> watchGoals(String uid) =>
      _doc(uid).snapshots().map((s) {
        if (s.exists && s.data() != null) {
          return UserGoals.fromJson(s.data());
        }
        return UserGoals.defaults;
      });

  /// Get robusto: tenta cache -> server; se falhar/unavailable,
  /// retorna `defaults`. Pode criar o doc padrão na 1ª vez.
  static Future<UserGoals> getGoals(String uid,
      {bool createIfMissing = true}) async {
    // 1) tenta pelo cache
    try {
      final c = await _doc(uid).get(const GetOptions(source: Source.cache));
      if (c.exists && c.data() != null) {
        return UserGoals.fromJson(c.data());
      }
    } catch (_) {
      // cache miss / sem persistência — ignora
    }

    // 2) tenta no servidor
    try {
      final s = await _doc(uid).get(const GetOptions(source: Source.server));
      if (s.exists && s.data() != null) {
        return UserGoals.fromJson(s.data());
      }
      // 3) não existe: cria defaults se solicitado
      if (createIfMissing) {
        final d = UserGoals.defaults;
        await _doc(uid).set(d.toJson(), SetOptions(merge: true));
        return d;
      }
      return UserGoals.defaults;
    } on FirebaseException catch (e) {
      // indisponível/offline: devolve defaults (UI segue funcionando)
      if (e.code == 'unavailable') return UserGoals.defaults;
      rethrow;
    }
  }

  static Future<void> saveGoals(String uid, UserGoals g) =>
      _doc(uid).set(g.toJson(), SetOptions(merge: true));

  /// Utilitário opcional para garantir o documento criado.
  static Future<void> ensureDefaults(String uid) async {
    final doc = await _doc(uid).get();
    if (!doc.exists) {
      await _doc(uid).set(UserGoals.defaults.toJson(), SetOptions(merge: true));
    }
  }
}
