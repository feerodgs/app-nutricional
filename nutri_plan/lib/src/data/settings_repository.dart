import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_goals.dart';

class SettingsRepository {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('settings').doc('goals');

  static Stream<UserGoals> watchGoals(String uid) =>
      _doc(uid).snapshots().map((s) => UserGoals.fromJson(s.data()));

  static Future<UserGoals> getGoals(String uid) async {
    final s = await _doc(uid).get();
    return UserGoals.fromJson(s.data());
  }

  static Future<void> saveGoals(String uid, UserGoals g) =>
      _doc(uid).set(g.toJson(), SetOptions(merge: true));
}
