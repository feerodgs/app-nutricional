// lib/src/models/app_user.dart
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// Entidade de usuário da aplicação.
/// Camada: Model (MVVM).
class AppUser {
  /// ID do Firebase Auth (imutável).
  final String uid;

  /// E-mail do usuário (opcional).
  final String? email;

  /// Nome exibido (opcional).
  final String? name;

  /// Última atualização (auditoria).
  final DateTime? lastUpdated;

  const AppUser({
    required this.uid,
    this.email,
    this.name,
    this.lastUpdated,
  });

  /// Serializa para Firestore/JSON.
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        // Firestore aceita DateTime diretamente e salva como Timestamp.
        'lastUpdated': lastUpdated?.toUtc(),
      }..removeWhere((k, v) => v == null);

  /// Constrói a partir de Firestore/JSON.
  factory AppUser.fromJson(Map<String, dynamic> map) {
    DateTime? _toDate(dynamic v) {
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
      lastUpdated: _toDate(map['lastUpdated']),
    );
  }

  /// Atalho para atualizar campos de perfil mantendo o uid.
  AppUser copyWith({
    String? email,
    String? name,
    DateTime? lastUpdated,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, name: $name, lastUpdated: $lastUpdated)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          name == other.name &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode => Object.hash(uid, email, name, lastUpdated);

  // Opcional: fábrica para adaptar de uma "tabela/DTO" externo.
  // Ajuste o tipo UserTableData conforme seu datasource/ORM.
  // factory AppUser.fromUserTableData(UserTableData row) => AppUser(
  //   uid: row.uid,
  //   email: row.email,
  //   name: row.name,
  //   lastUpdated: row.lastUpdated,
  // );
}
