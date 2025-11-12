import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';

class MealRepository {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('meals');

  // Lista todas (ou só do dia)
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

  // Histórico por intervalo
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

  // Cria refeição
  static Future<String> create(Meal meal) async {
    try {
      final ref = await _col(meal.userId).add(meal.toJson());
      log('Meal saved id=${ref.id}', name: 'MealRepository');
      return ref.id;
    } on FirebaseException catch (e) {
      log('Firestore create meal error: code=${e.code} msg=${e.message}',
          name: 'MealRepository', level: 1000);
      rethrow;
    } catch (e) {
      log('Unknown error on create: $e', name: 'MealRepository', level: 1000);
      rethrow;
    }
  }

  static Future<void> update(String uid, String mealId, Meal meal) async {
    try {
      await _col(uid).doc(mealId).set(meal.toJson(), SetOptions(merge: false));
    } on FirebaseException catch (e) {
      log('Firestore update meal error: code=${e.code} msg=${e.message}',
          name: 'MealRepository', level: 1000);
      rethrow;
    }
  }

  static Future<void> delete(String uid, String mealId) async {
    try {
      await _col(uid).doc(mealId).delete();
    } on FirebaseException catch (e) {
      log('Firestore delete meal error: code=${e.code} msg=${e.message}',
          name: 'MealRepository', level: 1000);
      rethrow;
    }
  }
}
