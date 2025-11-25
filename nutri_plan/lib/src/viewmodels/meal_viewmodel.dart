import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/meal_repository.dart';
import '../models/meal.dart';
import '../models/meal_item.dart';

class MealViewModel extends ChangeNotifier {
  bool saving = false;
  String? error;
  String name = 'Refeição';
  DateTime date = DateTime.now();
  final List<MealItem> items = [];

  void setName(String v) {
    name = v;
    notifyListeners();
  }

  void setDate(DateTime v) {
    date = v;
    notifyListeners();
  }

  void addItem(MealItem item) {
    items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    notifyListeners();
  }

  void updateItem(int index, MealItem item) {
    if (index < 0 || index >= items.length) return;
    items[index] = item;
    notifyListeners();
  }

  void clear() {
    name = 'Refeição';
    date = DateTime.now();
    items.clear();
    notifyListeners();
  }

  Future<String?> save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      error = 'Usuário não autenticado';
      notifyListeners();
      return null;
    }
    if (name.trim().isEmpty) {
      error = 'Informe o nome da refeição';
      notifyListeners();
      return null;
    }
    if (items.isEmpty) {
      error = 'Adicione pelo menos um item';
      notifyListeners();
      return null;
    }

    saving = true;
    error = null;
    notifyListeners();
    try {
      final meal = Meal(
        id: '',
        userId: user.uid,
        name: name.trim(),
        date: date,
        items: List.of(items),
        done: false,
      );
      final id = await MealRepository.create(meal);
      clear();
      return id;
    } on FirebaseException catch (e) {
      log('Meal save failed: code=${e.code} message=${e.message}',
          name: 'MealViewModel');
      error = _mapFsError(e);
      return null;
    } catch (e) {
      log('Meal save unknown error: $e', name: 'MealViewModel');
      error = 'Falha desconhecida ao salvar';
      return null;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  String _mapFsError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Sem permissão para gravar (regras do Firestore).';
      case 'unavailable':
        return 'Serviço indisponível. Tente novamente.';
      case 'cancelled':
        return 'Operação cancelada.';
      case 'invalid-argument':
        return 'Dados inválidos ao salvar.';
      case 'deadline-exceeded':
        return 'Tempo excedido na operação.';
      case 'resource-exhausted':
        return 'Cota/limite excedido.';
      default:
        return 'Erro Firestore: ${e.code}';
    }
  }
}
