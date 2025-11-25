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

  static Future<String> create(Meal meal) async {
    final ref = _col(meal.userId).doc();

    final data = Map<String, dynamic>.from(meal.toJson())
      ..remove('id')
      ..['userId'] = meal.userId;

    await ref.set(data);
    return ref.id;
  }

  static Future<void> save(Meal meal) async {
    final ref = _col(meal.userId).doc(meal.id.isEmpty ? null : meal.id);
    final data = Map<String, dynamic>.from(meal.toJson())
      ..remove('id')
      ..['userId'] = meal.userId;

    if (meal.id.isEmpty) {
      await ref.set(data);
    } else {
      await ref.update(data);
    }
  }

  static Future<void> update(
      String uid, String mealId, Map<String, dynamic> data) async {
    data['userId'] = uid;
    await _col(uid).doc(mealId).update(data);
  }

  static Future<void> delete(String uid, String mealId) async {
    await _col(uid).doc(mealId).delete();
  }

  static Future<List<Meal>> getByDay(String uid, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final q = await _col(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    return q.docs.map((d) => Meal.fromSnapshot(d.id, d.data())).toList();
  }

  static Future<List<String>> batchInsert(String uid, List<Meal> meals) async {
    if (meals.isEmpty) return [];

    const maxPerBatch = 450;
    final ids = <String>[];

    for (var i = 0; i < meals.length; i += maxPerBatch) {
      final slice = meals.sublist(
        i,
        (i + maxPerBatch > meals.length) ? meals.length : i + maxPerBatch,
      );

      final batch = _db.batch();

      for (final m in slice) {
        final doc = _col(uid).doc();
        ids.add(doc.id);

        final data = Map<String, dynamic>.from(m.toJson())
          ..remove('id')
          ..['userId'] = uid;

        batch.set(doc, data);
      }

      await batch.commit();
    }

    return ids;
  }

  static Future<List<String>> createMany(String uid, List<Meal> meals) {
    return batchInsert(uid, meals);
  }
}
