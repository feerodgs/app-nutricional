import 'package:flutter/material.dart';
import '../../../models/meal.dart';

class MealListTile extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  const MealListTile({super.key, required this.meal, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu),
        title: Text(meal.name),
        subtitle: Text('${_fmtDate(meal.date)} • ${meal.items.length} itens'),
        trailing: Text('${meal.totalKcal.toStringAsFixed(0)} kcal',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        onTap: onTap,
      ),
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }
}
