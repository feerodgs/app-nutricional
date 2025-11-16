import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';

class MealRepository {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('meals');

  static Stream<List<Meal>> watchAll(String uid, {DateTime? day}) {
    Query<Map<String, dynamic>> q = _col(uid).orderBy('date', descending: true);
    if (day != null) {
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      q = _col(uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .orderBy('date', descending: true);
    }
    return q.snapshots().map(
          (s) => s.docs.map((d) => Meal.fromSnapshot(d.id, d.data())).toList(),
        );
  }

  static Stream<List<Meal>> watchRangeHistory(
      String uid, DateTime start, DateTime end) {
    final q = _col(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true);
    return q.snapshots().map(
          (s) => s.docs.map((d) => Meal.fromSnapshot(d.id, d.data())).toList(),
        );
  }

  // >>> robusto + log
  static Future<String> create(Meal meal) async {
    final ref = _col(meal.userId).doc();
    if (kDebugMode) {
      print('WRITE -> users/${meal.userId}/meals/${ref.id}');
      print('PAYLOAD -> ${meal.toJson()}');
    }
    await ref.set(meal.toJson()); // grava
    return ref.id;
  }

  static Future<void> update(String uid, String mealId, Meal meal) async {
    await _col(uid).doc(mealId).set(meal.toJson(), SetOptions(merge: true));
  }

  static Future<void> delete(String uid, String mealId) async {
    await _col(uid).doc(mealId).delete();
  }
}
