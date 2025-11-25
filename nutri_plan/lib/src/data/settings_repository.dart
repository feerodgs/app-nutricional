import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_goals.dart';

class SettingsRepository {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('settings').doc('goals');

  static Stream<UserGoals> watchGoals(String uid) =>
      _doc(uid).snapshots().map((s) {
        final data = s.data();
        if (data != null) {
          return UserGoals.fromJson(data);
        }
        return UserGoals.defaults;
      });

  static Future<UserGoals> getGoals(String uid,
      {bool createIfMissing = true}) async {
    // 1) CACHE
    try {
      final c = await _doc(uid).get(const GetOptions(source: Source.cache));
      final data = c.data();
      if (data != null) {
        return UserGoals.fromJson(data);
      }
    } catch (_) {}

    // 2) SERVER
    try {
      final s = await _doc(uid).get(const GetOptions(source: Source.server));
      final data = s.data();
      if (data != null) {
        return UserGoals.fromJson(data);
      }

      // 3) Criar metas padrão
      if (createIfMissing) {
        final d = UserGoals.defaults;
        await _doc(uid).set(d.toJson(), SetOptions(merge: true));
        return d;
      }

      return UserGoals.defaults;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') return UserGoals.defaults;
      rethrow;
    }
  }

  static Future<void> saveGoals(String uid, UserGoals g) =>
      _doc(uid).set(g.toJson(), SetOptions(merge: true));

  static Future<void> setGoals(String uid, UserGoals goals) async =>
      _doc(uid).set(goals.toJson(), SetOptions(merge: true));

  static Future<void> ensureDefaults(String uid) async {
    final doc = await _doc(uid).get();
    if (!doc.exists) {
      await _doc(uid).set(UserGoals.defaults.toJson(), SetOptions(merge: true));
    }
  }
}
