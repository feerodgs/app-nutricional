import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_goals.dart';

class SettingsRepository {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('settings').doc('goals');

  static Stream<UserGoals> watchGoals(String uid) {
    return _doc(uid).snapshots().map((snap) {
      final data = snap.data();

      if (data == null) {
        return UserGoals.defaults;
      }

      return UserGoals.fromJson(_normalize(data));
    });
  }

  static Future<UserGoals> getGoals(String uid,
      {bool createIfMissing = true}) async {
    try {
      final cache = await _doc(uid).get(const GetOptions(source: Source.cache));
      if (cache.data() != null) {
        return UserGoals.fromJson(_normalize(cache.data()!));
      }
    } catch (_) {}

    try {
      final server =
          await _doc(uid).get(const GetOptions(source: Source.server));

      final data = server.data();

      if (data != null) {
        return UserGoals.fromJson(_normalize(data));
      }

      if (createIfMissing) {
        final d = UserGoals.defaults;
        await _doc(uid).set(d.toJson(), SetOptions(merge: true));
        return d;
      }

      return UserGoals.defaults;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        return UserGoals.defaults;
      }
      rethrow;
    }
  }

  static Future<void> saveGoals(String uid, UserGoals g) {
    return _doc(uid).set(g.toJson(), SetOptions(merge: true));
  }

  static Future<void> setGoals(String uid, UserGoals goals) async {
    await _doc(uid).set(goals.toJson(), SetOptions(merge: true));
  }

  static Future<void> ensureDefaults(String uid) async {
    final doc = await _doc(uid).get();
    if (!doc.exists) {
      await _doc(uid).set(UserGoals.defaults.toJson(), SetOptions(merge: true));
    }
  }

  static Map<String, dynamic> _normalize(Map<String, dynamic> json) {
    return {
      'kcal': (json['kcal'] ?? 2000).toDouble(),
      'protein': (json['protein'] ?? 100).toDouble(),
      'carbs': (json['carbs'] ?? 200).toDouble(),
      'fat': (json['fat'] ?? 60).toDouble(),
      'goalType': json['goalType'] ?? 'maintenance',
    };
  }
}
