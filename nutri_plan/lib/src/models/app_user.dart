import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class AppUser {
  final String uid;
  final String? email;
  final String? name;
  final DateTime? lastUpdated;

  /// novo campo
  final bool finishedOnboarding;

  const AppUser({
    required this.uid,
    this.email,
    this.name,
    this.lastUpdated,
    this.finishedOnboarding = false,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'lastUpdated': lastUpdated?.toUtc(),
        'finishedOnboarding': finishedOnboarding,
      }..removeWhere((k, v) => v == null);

  factory AppUser.fromJson(Map<String, dynamic> map) {
    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return null;
    }

    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      name: map['name'] as String?,
      lastUpdated: toDate(map['lastUpdated']),
      finishedOnboarding: map['finishedOnboarding'] == true,
    );
  }

  AppUser copyWith({
    String? email,
    String? name,
    DateTime? lastUpdated,
    bool? finishedOnboarding,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      finishedOnboarding: finishedOnboarding ?? this.finishedOnboarding,
    );
  }
}
