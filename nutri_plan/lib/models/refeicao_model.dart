import 'package:cloud_firestore/cloud_firestore.dart';

class Refeicao {
  // O ID do documento no Firestore, opcional ao criar (será gerado)
  final String? id;
  final String nome; // Ex: Café da Manhã, Almoço, Lanche, etc.
  final DateTime dataHora; // Quando a refeição foi consumida
  final String?
  tipoRefeicao; // Ex: Breakfast, Lunch, Dinner, Snack (para filtros)

  // Valores Nutricionais (Macros)
  final double calorias;
  final double carboidratos;
  final double proteinas;
  final double gorduras;

  // Imagem e Observações
  final String? imageUrl; // URL da imagem salva no Firebase Storage
  final String? observacoes;

  Refeicao({
    this.id,
    required this.nome,
    required this.dataHora,
    this.tipoRefeicao,
    required this.calorias,
    required this.carboidratos,
    required this.proteinas,
    required this.gorduras,
    this.imageUrl,
    this.observacoes,
  });

  // Converte o objeto Dart para um Map<String, dynamic> para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'dataHora': dataHora, // O Firestore lida com DateTime
      'tipoRefeicao': tipoRefeicao,
      'calorias': calorias,
      'carboidratos': carboidratos,
      'proteinas': proteinas,
      'gorduras': gorduras,
      'imageUrl': imageUrl,
      'observacoes': observacoes,
    };
  }

  // Cria um objeto Refeicao a partir de um DocumentSnapshot do Firestore
  factory Refeicao.fromFirestore(snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    // Converte o Timestamp do Firestore de volta para DateTime
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      // Tentativa de parse de string caso o Timestamp não esteja disponível (improvável)
      if (value is String) {
        return DateTime.parse(value);
      }
      return DateTime.now(); // Valor fallback
    }

    return Refeicao(
      id: snapshot.id, // O ID do documento é essencial
      nome: data['nome'] ?? 'Refeição Desconhecida',
      dataHora: parseDateTime(data['dataHora']),
      tipoRefeicao: data['tipoRefeicao'],
      calorias: (data['calorias'] as num?)?.toDouble() ?? 0.0,
      carboidratos: (data['carboidratos'] as num?)?.toDouble() ?? 0.0,
      proteinas: (data['proteinas'] as num?)?.toDouble() ?? 0.0,
      gorduras: (data['gorduras'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'],
      observacoes: data['observacoes'],
    );
  }
}
