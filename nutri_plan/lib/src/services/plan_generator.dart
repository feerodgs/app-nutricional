// lib/src/services/plan_generator.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

/// ===============================
/// MODELOS (PUROS)
/// ===============================
class Food {
  final String food;
  final String unit; // ex.: g, ml, un
  final double per; // base da porção (ex.: 100 g, 200 ml, 1 un)
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> tags;

  Food({
    required this.food,
    required this.unit,
    required this.per,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.tags,
  });

  factory Food.fromJson(Map<String, dynamic> m) => Food(
        food: m['food'] as String,
        unit: m['unit'] as String,
        per: (m['per'] as num).toDouble(),
        kcal: (m['kcal'] as num).toDouble(),
        protein: (m['protein'] as num).toDouble(),
        carbs: (m['carbs'] as num).toDouble(),
        fat: (m['fat'] as num).toDouble(),
        tags: List<String>.from(m['tags'] ?? const []),
      );
}

class PlanItem {
  final String food;
  final String unit;
  final double quantity; // na MESMA unidade de 'unit'
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  const PlanItem({
    required this.food,
    required this.unit,
    required this.quantity,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
        'food': food,
        'unit': unit,
        'quantity': quantity,
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
}

class PlanMeal {
  final String name; // ex.: "Café da manhã"
  final List<PlanItem> items;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  const PlanMeal({
    required this.name,
    required this.items,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'items': items.map((e) => e.toJson()).toList(),
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
}

class PlanDay {
  final int index; // 1..N
  final List<PlanMeal> meals;
  final double kcalDay;
  final double proteinDay;
  final double carbsDay;
  final double fatDay;

  const PlanDay({
    required this.index,
    required this.meals,
    required this.kcalDay,
    required this.proteinDay,
    required this.carbsDay,
    required this.fatDay,
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'meals': meals.map((m) => m.toJson()).toList(),
        'kcalDay': kcalDay,
        'proteinDay': proteinDay,
        'carbsDay': carbsDay,
        'fatDay': fatDay,
      };
}

/// ===============================
/// GERADOR
/// ===============================
class PlanGenerator {
  final List<Food> _foods;
  final Random _rng;

  // Índices/precomputados
  final Map<String, List<Food>> _byTag = {};
  late final List<Food> _protDense; // alimentos mais densos em proteína
  late final List<Food> _carbDense; // mais densos em carbo
  late final List<Food> _fatDense; // mais densos em gordura

  PlanGenerator._(this._foods, this._rng);

  factory PlanGenerator.fromFoods({
    required List<Food> foods,
    required Random rng,
  }) =>
      PlanGenerator._(foods, rng);

  static Future<PlanGenerator> loadFromAssets(
    String path, {
    int? randomSeed,
  }) async {
    final raw = await rootBundle.loadString(path);
    final list = (json.decode(raw) as List)
        .map((e) => Food.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return PlanGenerator.fromFoods(foods: list, rng: Random(randomSeed));
  }

  /// Chame 1x após criar o generator (pré-indexa para ficar rápido)
  void buildIndexes() {
    // por tag (lowercase)
    for (final f in _foods) {
      for (final t in f.tags) {
        final k = t.toLowerCase();
        (_byTag[k] ??= []).add(f);
      }
    }
    // listas por densidade (desc)
    _protDense = List<Food>.from(_foods)
      ..sort((a, b) => (b.protein / b.per).compareTo(a.protein / a.per));
    _carbDense = List<Food>.from(_foods)
      ..sort((a, b) => (b.carbs / b.per).compareTo(a.carbs / a.per));
    _fatDense = List<Food>.from(_foods)
      ..sort((a, b) => (b.fat / b.per).compareTo(a.fat / a.per));
  }

  Food? _pickByTagFast(String tagLC) {
    final list = _byTag[tagLC];
    if (list == null || list.isEmpty) return null;
    return list[_rng.nextInt(list.length)];
  }

  Food _pickProteinFallback() => _protDense.first;
  Food _pickCarbFallback() => _carbDense.first;
  Food _pickFatFallback() => _fatDense.first;

  /// Geração determinística simples por metas/dia.
  /// Tolerância de ~10% em kcal; macros por refeição ajustadas via porções.
  Future<List<PlanDay>> generate({
    required double kcalTarget,
    required double proteinTarget,
    required double carbsTarget,
    required double fatTarget,
    required int days,
    required int mealsPerDay,
    List<String> dislikes = const [], // ex.: ["banana"]
    List<String> allergies = const [], // ex.: ["laticinio", "gluten"]
  }) async {
    // Filtra por preferências
    final dislikesLC = dislikes.map((e) => e.toLowerCase().trim()).toList();
    final allergiesLC = allergies.map((e) => e.toLowerCase().trim()).toList();

    final allowed = _foods.where((f) {
      final nameLC = f.food.toLowerCase();
      final dislikeHit =
          dislikesLC.any((d) => d.isNotEmpty && nameLC.contains(d));
      final tagLC = f.tags.map((t) => t.toLowerCase()).toList();
      final allergyHit =
          allergiesLC.any((a) => a.isNotEmpty && tagLC.contains(a));
      return !dislikeHit && !allergyHit;
    }).toList();

    if (allowed.isEmpty) {
      throw StateError('Lista de alimentos permitidos está vazia.');
    }

    // Distribuição leve das refeições (café e última com peso 1.1)
    final weights = List<double>.filled(mealsPerDay, 1.0);
    if (mealsPerDay >= 3) {
      weights[0] = 1.1;
      weights[mealsPerDay - 1] = 1.1;
    }
    final wSum = weights.reduce((a, b) => a + b);

    final out = <PlanDay>[];

    for (int d = 1; d <= days; d++) {
      final dayMeals = <PlanMeal>[];
      double dayK = 0, dayP = 0, dayC = 0, dayF = 0;

      for (int m = 0; m < mealsPerDay; m++) {
        final share = weights[m] / wSum;
        final mk = max(0, kcalTarget * share);
        final mp = max(0, proteinTarget * share);
        final mc = max(0, carbsTarget * share);
        final mf = max(0, fatTarget * share);

        // Seleção por tag, fallback por densidade
        final prot = _pickByTagFast('proteina') ?? _pickProteinFallback();
        final carb = _pickByTagFast('carbo') ?? _pickCarbFallback();
        final fat = _pickByTagFast('gordura') ?? _pickFatFallback();

        final items = <PlanItem>[];
        double tk = 0, tp = 0, tc = 0, tf = 0;

        void addPortion(Food f, double qty) {
          final factor = qty / f.per;
          final k = f.kcal * factor;
          final p = f.protein * factor;
          final c = f.carbs * factor;
          final g = f.fat * factor;

          final niceQty = _roundNice(qty);
          items.add(PlanItem(
            food: f.food,
            unit: f.unit,
            quantity: niceQty,
            kcal: k,
            protein: p,
            carbs: c,
            fat: g,
          ));

          tk += k;
          tp += p;
          tc += c;
          tf += g;
        }

        // porções-alvo por macro (gr/ml -> por unidade de 'per')
        if (mp > 0 && prot.protein > 0) {
          final gramsPerUnit = prot.protein / prot.per;
          final qtyProt = mp / gramsPerUnit;
          addPortion(prot, qtyProt);
        }
        if (mc > 0 && carb.carbs > 0) {
          final gramsPerUnit = carb.carbs / carb.per;
          final qtyCarb = mc / gramsPerUnit;
          addPortion(carb, qtyCarb);
        }
        if (mf > 0 && fat.fat > 0) {
          final gramsPerUnit = fat.fat / fat.per;
          final qtyFat = mf / gramsPerUnit;
          addPortion(fat, qtyFat);
        }

        // Ajuste fino de kcal (±10%)
        const tol = 0.10;
        final minK = mk * (1 - tol);
        final maxK = mk * (1 + tol);

        if (tk < minK && carb.kcal > 0) {
          final kPerUnit = carb.kcal / carb.per;
          final falta = minK - tk;
          final addQty = falta / kPerUnit;
          addPortion(carb, addQty);
        } else if (tk > maxK && items.isNotEmpty) {
          // reduz o item mais calórico
          items.sort((a, b) => b.kcal.compareTo(a.kcal));
          final first = items.first;

          // acha o Food correspondente
          final f = allowed.firstWhere((x) => x.food == first.food,
              orElse: () => carb);

          if (first.kcal > 0) {
            final kPerQty = first.kcal / max(1e-6, first.quantity);
            final sobra = tk - maxK;
            final reducQty =
                min(first.quantity * 0.5, sobra / max(1e-6, kPerQty));
            final newQty = max(0, first.quantity - reducQty);

            // remove anterior
            items.removeAt(0);
            tk -= first.kcal;
            tp -= first.protein;
            tc -= first.carbs;
            tf -= first.fat;

            if (newQty > 0) {
              final factor = newQty / f.per;
              final nk = f.kcal * factor;
              final np = f.protein * factor;
              final nc = f.carbs * factor;
              final ng = f.fat * factor;

              items.insert(
                0,
                PlanItem(
                  food: f.food,
                  unit: f.unit,
                  quantity: _roundNice(newQty),
                  kcal: nk,
                  protein: np,
                  carbs: nc,
                  fat: ng,
                ),
              );
              tk += nk;
              tp += np;
              tc += nc;
              tf += ng;
            }
          }
        }

        final meal = PlanMeal(
          name: _mealName(m),
          items: items,
          kcal: tk,
          protein: tp,
          carbs: tc,
          fat: tf,
        );
        dayMeals.add(meal);
        dayK += tk;
        dayP += tp;
        dayC += tc;
        dayF += tf;
      }

      out.add(PlanDay(
        index: d,
        meals: dayMeals,
        kcalDay: dayK,
        proteinDay: dayP,
        carbsDay: dayC,
        fatDay: dayF,
      ));
    }

    return out;
  }

  String _mealName(int idx) {
    switch (idx) {
      case 0:
        return 'Café da manhã';
      case 1:
        return 'Almoço';
      case 2:
        return 'Lanche';
      case 3:
        return 'Jantar';
      default:
        return 'Refeição ${idx + 1}';
    }
  }

  double _roundNice(num v) {
    if (v.isNaN || v.isInfinite) return 0;
    // arredonda para múltiplos de 5 (g/ml)
    return (v / 5).roundToDouble() * 5;
  }
}
