import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/refeicao_model.dart';
import '../models/user_profile_model.dart'; // NOVO: Importa o modelo de perfil

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  // Coleção principal de usuários
  late final CollectionReference usersRef;
  // Referência tipada para a subcoleção de refeições do usuário
  late final CollectionReference<Refeicao> refeicoesRef;

  DataService() {
    if (_userId == null) {
      // Se for instanciado antes do login, inicializa apenas a referência principal
      usersRef = _db.collection('users');
      // A referência de refeições será inicializada apenas se houver userId,
      // mas como o DataService só é instanciado no AuthGate (após o login),
      // geralmente _userId não será null.
      if (FirebaseAuth.instance.currentUser != null) {
        _initializeUserCollections();
      }
    } else {
      _initializeUserCollections();
    }
  }

  void _initializeUserCollections() {
    usersRef = _db.collection('users');

    // Inicializa a referência tipada para as refeições
    refeicoesRef = _db
        .collection('users')
        .doc(_userId)
        .collection('refeicoes')
        .withConverter<Refeicao>(
          fromFirestore: (snapshot, _) => Refeicao.fromFirestore(snapshot),
          toFirestore: (refeicao, _) => refeicao.toFirestore(),
        );
  }

  // ------------------------------------------
  // FUNÇÕES DE PERFIL DO USUÁRIO
  // ------------------------------------------

  // NOVO: Cria o documento de perfil do usuário no Firestore após o cadastro no Auth
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      // Usa set() com merge: true para criar ou atualizar o documento do usuário
      // O ID do documento é o mesmo ID do usuário do Firebase Auth
      await usersRef
          .doc(profile.userId)
          .set(profile.toFirestore(), SetOptions(merge: true));
      print(
        'Perfil do usuário criado/atualizado com sucesso: ${profile.userId}',
      );
    } catch (e) {
      print('Erro ao criar perfil do usuário: $e');
    }
  }

  // ------------------------------------------
  // FUNÇÕES DE STORAGE (IMAGENS)
  // ------------------------------------------

  // Função para fazer upload de uma imagem e retornar a URL
  Future<String?> uploadImage(File imageFile) async {
    if (_userId == null) return null;

    final fileName =
        'refeicoes/${_userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final storageRef = _storage.ref().child(fileName);

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      final uploadTask = storageRef.putFile(imageFile, metadata);

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print('Erro no upload da imagem: ${e.code} - ${e.message}');
      return null;
    }
  }

  // ------------------------------------------
  // FUNÇÕES DE FIRESTORE (REFEIÇÕES)
  // ------------------------------------------

  // Salva um objeto Refeicao no Firestore
  Future<void> saveRefeicao(Refeicao refeicao) async {
    // Garante que o DataService está pronto para operar
    if (_userId == null) {
      print("Erro: Usuário não logado ao tentar salvar refeição.");
      return;
    }
    try {
      await refeicoesRef.add(refeicao);
      print('Refeição salva com sucesso: ${refeicao.nome}');
    } catch (e) {
      print('Erro ao salvar refeição: $e');
    }
  }

  // Obtém as refeições de um determinado dia (Stream em tempo real)
  Stream<List<Refeicao>> getRefeicoesDoDia(DateTime day) {
    if (_userId == null) {
      // Retorna um stream vazio se não houver userId
      return Stream.value([]);
    }

    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    return refeicoesRef
        .where('dataHora', isGreaterThanOrEqualTo: startOfDay)
        .where('dataHora', isLessThanOrEqualTo: endOfDay)
        // OBSERVAÇÃO: A query deve incluir orderby('dataHora') para funcionar com o where,
        // mas para fins de TCC e evitar erros de índice, vamos ordenar no cliente.
        // No entanto, para funcionar corretamente com filtros de data, manterei a ordenação no servidor.
        // Se o Firebase reclamar de 'missing index', você precisará criá-lo no console.
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Função de Exemplo para Deletar Refeição
  Future<void> deleteRefeicao(String refeicaoId) async {
    if (_userId == null) return;
    try {
      await refeicoesRef.doc(refeicaoId).delete();
      print('Refeição $refeicaoId deletada.');
    } catch (e) {
      print('Erro ao deletar refeição: $e');
    }
  }
}
