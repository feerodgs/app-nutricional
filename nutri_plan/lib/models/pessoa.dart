import 'package:cloud_firestore/cloud_firestore.dart';

/// ===== ENUMS =====
enum Genero { masculino, feminino, naoInformado }

enum ObjetivoPrincipal {
  emagrecer,
  ganharMassa,
  melhorarSaude,
  controlarCondicao,
  reeducacao
}

enum NivelAtividade { sedentario, leve, moderado, intenso }

enum EstiloPlano { flexivel, regrado }

enum Estresse { baixo, medio, alto }

/// ===== CLASSE PESSOA =====
class Pessoa {
  // Identificação
  final String uid; // ID do usuário (Firebase Auth)
  final String? nome;
  final DateTime? dataNascimento;

  // Medidas
  final double? alturaCm;
  final double? pesoKg;
  final Genero genero;

  // Saúde e condições
  final List<String> condicoesSaude;
  final List<String> medicamentos;
  final List<String> restricoes;
  final List<String> preferencias;

  // Objetivos
  final ObjetivoPrincipal objetivoPrincipal;
  final String? metaEspecifica;
  final DateTime? metaPrazo;
  final int? comprometimento; // Escala 1-10

  // Rotina / estilo de vida
  final NivelAtividade nivelAtividade;
  final List<String> atividades;
  final double? horasSono;
  final int? refeicoesDia;
  final String? refeicaoPulada;
  final int? comeForaSemanas;
  final Estresse estresse;

  // Alimentação
  final String? descricaoAlimentacao;
  final String? alcoolFrequencia;
  final String? refriFrequencia;
  final double? aguaLitrosDia;

  // Comportamento e motivação
  final List<String> motivacoes;
  final String? historicoDietas;
  final List<String> principaisDificuldades;
  final EstiloPlano estiloPlano;

  // Preferências do app
  final bool querLembretes;
  final bool querSugestoesSubstituicao;
  final bool integrarFitness;
  final bool acompanharFotosMedidas;

  // Metadados
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ===== CONSTRUTOR =====
  Pessoa({
    required this.uid,
    this.nome,
    this.dataNascimento,
    this.alturaCm,
    this.pesoKg,
    this.genero = Genero.naoInformado,
    this.condicoesSaude = const [],
    this.medicamentos = const [],
    this.restricoes = const [],
    this.preferencias = const [],
    this.objetivoPrincipal = ObjetivoPrincipal.reeducacao,
    this.metaEspecifica,
    this.metaPrazo,
    this.comprometimento,
    this.nivelAtividade = NivelAtividade.sedentario,
    this.atividades = const [],
    this.horasSono,
    this.refeicoesDia,
    this.refeicaoPulada,
    this.comeForaSemanas,
    this.estresse = Estresse.medio,
    this.descricaoAlimentacao,
    this.alcoolFrequencia,
    this.refriFrequencia,
    this.aguaLitrosDia,
    this.motivacoes = const [],
    this.historicoDietas,
    this.principaisDificuldades = const [],
    this.estiloPlano = EstiloPlano.flexivel,
    this.querLembretes = true,
    this.querSugestoesSubstituicao = true,
    this.integrarFitness = false,
    this.acompanharFotosMedidas = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// ===== SERIALIZAÇÃO =====

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'dataNascimento': _toTimestamp(dataNascimento),
      'alturaCm': alturaCm,
      'pesoKg': pesoKg,
      'genero': genero.name,
      'condicoesSaude': condicoesSaude,
      'medicamentos': medicamentos,
      'restricoes': restricoes,
      'preferencias': preferencias,
      'objetivoPrincipal': objetivoPrincipal.name,
      'metaEspecifica': metaEspecifica,
      'metaPrazo': _toTimestamp(metaPrazo),
      'comprometimento': comprometimento,
      'nivelAtividade': nivelAtividade.name,
      'atividades': atividades,
      'horasSono': horasSono,
      'refeicoesDia': refeicoesDia,
      'refeicaoPulada': refeicaoPulada,
      'comeForaSemanas': comeForaSemanas,
      'estresse': estresse.name,
      'descricaoAlimentacao': descricaoAlimentacao,
      'alcoolFrequencia': alcoolFrequencia,
      'refriFrequencia': refriFrequencia,
      'aguaLitrosDia': aguaLitrosDia,
      'motivacoes': motivacoes,
      'historicoDietas': historicoDietas,
      'principaisDificuldades': principaisDificuldades,
      'estiloPlano': estiloPlano.name,
      'querLembretes': querLembretes,
      'querSugestoesSubstituicao': querSugestoesSubstituicao,
      'integrarFitness': integrarFitness,
      'acompanharFotosMedidas': acompanharFotosMedidas,
      'createdAt': _toTimestamp(createdAt),
      'updatedAt': _toTimestamp(updatedAt),
    };
  }

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    return Pessoa(
      uid: map['uid'] ?? '',
      nome: map['nome'],
      dataNascimento: _fromTimestamp(map['dataNascimento']),
      alturaCm: _toDouble(map['alturaCm']),
      pesoKg: _toDouble(map['pesoKg']),
      genero: _parseEnum(Genero.values, map['genero'], Genero.naoInformado),
      condicoesSaude: _toStringList(map['condicoesSaude']),
      medicamentos: _toStringList(map['medicamentos']),
      restricoes: _toStringList(map['restricoes']),
      preferencias: _toStringList(map['preferencias']),
      objetivoPrincipal: _parseEnum(
        ObjetivoPrincipal.values,
        map['objetivoPrincipal'],
        ObjetivoPrincipal.reeducacao,
      ),
      metaEspecifica: map['metaEspecifica'],
      metaPrazo: _fromTimestamp(map['metaPrazo']),
      comprometimento: _toInt(map['comprometimento']),
      nivelAtividade: _parseEnum(
        NivelAtividade.values,
        map['nivelAtividade'],
        NivelAtividade.sedentario,
      ),
      atividades: _toStringList(map['atividades']),
      horasSono: _toDouble(map['horasSono']),
      refeicoesDia: _toInt(map['refeicoesDia']),
      refeicaoPulada: map['refeicaoPulada'],
      comeForaSemanas: _toInt(map['comeForaSemanas']),
      estresse: _parseEnum(Estresse.values, map['estresse'], Estresse.medio),
      descricaoAlimentacao: map['descricaoAlimentacao'],
      alcoolFrequencia: map['alcoolFrequencia'],
      refriFrequencia: map['refriFrequencia'],
      aguaLitrosDia: _toDouble(map['aguaLitrosDia']),
      motivacoes: _toStringList(map['motivacoes']),
      historicoDietas: map['historicoDietas'],
      principaisDificuldades: _toStringList(map['principaisDificuldades']),
      estiloPlano: _parseEnum(
          EstiloPlano.values, map['estiloPlano'], EstiloPlano.flexivel),
      querLembretes: map['querLembretes'] ?? true,
      querSugestoesSubstituicao: map['querSugestoesSubstituicao'] ?? true,
      integrarFitness: map['integrarFitness'] ?? false,
      acompanharFotosMedidas: map['acompanharFotosMedidas'] ?? false,
      createdAt: _fromTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: _fromTimestamp(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Pessoa copyWith({
    String? uid,
    String? nome,
    DateTime? dataNascimento,
    double? alturaCm,
    double? pesoKg,
    Genero? genero,
    List<String>? condicoesSaude,
    List<String>? medicamentos,
    List<String>? restricoes,
    List<String>? preferencias,
    ObjetivoPrincipal? objetivoPrincipal,
    String? metaEspecifica,
    DateTime? metaPrazo,
    int? comprometimento,
    NivelAtividade? nivelAtividade,
    List<String>? atividades,
    double? horasSono,
    int? refeicoesDia,
    String? refeicaoPulada,
    int? comeForaSemanas,
    Estresse? estresse,
    String? descricaoAlimentacao,
    String? alcoolFrequencia,
    String? refriFrequencia,
    double? aguaLitrosDia,
    List<String>? motivacoes,
    String? historicoDietas,
    List<String>? principaisDificuldades,
    EstiloPlano? estiloPlano,
    bool? querLembretes,
    bool? querSugestoesSubstituicao,
    bool? integrarFitness,
    bool? acompanharFotosMedidas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pessoa(
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      alturaCm: alturaCm ?? this.alturaCm,
      pesoKg: pesoKg ?? this.pesoKg,
      genero: genero ?? this.genero,
      condicoesSaude: condicoesSaude ?? this.condicoesSaude,
      medicamentos: medicamentos ?? this.medicamentos,
      restricoes: restricoes ?? this.restricoes,
      preferencias: preferencias ?? this.preferencias,
      objetivoPrincipal: objetivoPrincipal ?? this.objetivoPrincipal,
      metaEspecifica: metaEspecifica ?? this.metaEspecifica,
      metaPrazo: metaPrazo ?? this.metaPrazo,
      comprometimento: comprometimento ?? this.comprometimento,
      nivelAtividade: nivelAtividade ?? this.nivelAtividade,
      atividades: atividades ?? this.atividades,
      horasSono: horasSono ?? this.horasSono,
      refeicoesDia: refeicoesDia ?? this.refeicoesDia,
      refeicaoPulada: refeicaoPulada ?? this.refeicaoPulada,
      comeForaSemanas: comeForaSemanas ?? this.comeForaSemanas,
      estresse: estresse ?? this.estresse,
      descricaoAlimentacao: descricaoAlimentacao ?? this.descricaoAlimentacao,
      alcoolFrequencia: alcoolFrequencia ?? this.alcoolFrequencia,
      refriFrequencia: refriFrequencia ?? this.refriFrequencia,
      aguaLitrosDia: aguaLitrosDia ?? this.aguaLitrosDia,
      motivacoes: motivacoes ?? this.motivacoes,
      historicoDietas: historicoDietas ?? this.historicoDietas,
      principaisDificuldades:
          principaisDificuldades ?? this.principaisDificuldades,
      estiloPlano: estiloPlano ?? this.estiloPlano,
      querLembretes: querLembretes ?? this.querLembretes,
      querSugestoesSubstituicao:
          querSugestoesSubstituicao ?? this.querSugestoesSubstituicao,
      integrarFitness: integrarFitness ?? this.integrarFitness,
      acompanharFotosMedidas:
          acompanharFotosMedidas ?? this.acompanharFotosMedidas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ===== HELPERS =====

  static Timestamp? _toTimestamp(DateTime? dt) =>
      dt == null ? null : Timestamp.fromDate(dt);

  static DateTime? _fromTimestamp(dynamic ts) {
    if (ts == null) return null;
    if (ts is Timestamp) return ts.toDate();
    if (ts is DateTime) return ts;
    return DateTime.tryParse(ts.toString());
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static List<String> _toStringList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  static T _parseEnum<T>(List<T> values, dynamic value, T fallback) {
    if (value == null) return fallback;
    try {
      return values.firstWhere((e) => (e as dynamic).name == value);
    } catch (_) {
      return fallback;
    }
  }
}
