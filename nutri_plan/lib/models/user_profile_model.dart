import 'package:cloud_firestore/cloud_firestore.dart';

enum Objetivo { emagrecer, ganharPeso, manterPeso }

enum Sexo { feminino, masculino }

enum NivelAtividade { leve, moderado, intenso }

class UserProfile {
  final String userId;
  final String email;
  final String? nome;
  final String? photoUrl;

  // --- NOVOS CAMPOS DO ONBOARDING ---
  final Objetivo? objetivo;
  final Sexo? sexo;
  final DateTime? dataNascimento;
  final double? pesoAtual; // em kg
  final int? altura; // em cm
  final double? metaPeso; // em kg
  final NivelAtividade? nivelAtividade;
  final int? numRefeicoes;
  final int? metaSemanas;

  final DateTime? createdAt;

  UserProfile({
    required this.userId,
    required this.email,
    this.nome,
    this.photoUrl,
    this.objetivo,
    this.sexo,
    this.dataNascimento,
    this.pesoAtual,
    this.altura,
    this.metaPeso,
    this.nivelAtividade,
    this.numRefeicoes,
    this.metaSemanas,
    this.createdAt,
  });

  // Converte o objeto para o formato do Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nome': nome,
      'photoUrl': photoUrl,
      'objetivo': objetivo?.name, // Salva o nome do enum como String
      'sexo': sexo?.name,
      'dataNascimento': dataNascimento,
      'pesoAtual': pesoAtual,
      'altura': altura,
      'metaPeso': metaPeso,
      'nivelAtividade': nivelAtividade?.name,
      'numRefeicoes': numRefeicoes,
      'metaSemanas': metaSemanas,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  // Cria o objeto a partir de um documento do Firestore
  factory UserProfile.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    // O Firestore retorna um objeto Timestamp, não uma String.
    // Precisamos convertê-lo para DateTime.
    final Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;
    final Timestamp? dataNascimentoTimestamp =
        data['dataNascimento'] as Timestamp?;

    return UserProfile(
      userId: doc.id,
      email: data['email'] as String,
      nome: data['nome'] as String?,
      photoUrl: data['photoUrl'] as String?, // <-- NOVO CAMPO ADICIONADO
      dataNascimento: dataNascimentoTimestamp?.toDate(),
      createdAt: createdAtTimestamp?.toDate(),
    );
  }
}
