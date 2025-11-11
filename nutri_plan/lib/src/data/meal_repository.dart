import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';

class MealRepository {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('meals');

  static Future<String> create(Meal meal) async {
    final ref = await _col(meal.userId).add(meal.toJson());
    return ref.id;
  }

  static Stream<List<Meal>> watchAll(String uid, {DateTime? day}) {
    Query<Map<String, dynamic>> q = _col(uid).orderBy('date', descending: true);
    if (day != null) {
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      q = q
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThan: end);
    }
    return q.snapshots().map(
        (s) => s.docs.map((d) => Meal.fromSnapshot(d.id, d.data())).toList());
  }

  static Future<void> delete(String uid, String mealId) =>
      _col(uid).doc(mealId).delete();

  static Stream<List<Meal>> watchRange(
      String uid, DateTime start, DateTime end) {
    final q = _col(uid)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .orderBy('date', descending: true);
    return q.snapshots().map(
        (s) => s.docs.map((d) => Meal.fromSnapshot(d.id, d.data())).toList());
  }
}
