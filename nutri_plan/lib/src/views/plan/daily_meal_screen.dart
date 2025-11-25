import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/daily_meal_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyMealScreen extends StatelessWidget {
  const DailyMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return ChangeNotifierProvider(
      create: (_) => DailyMealViewModel()..load(uid),
      child: Consumer<DailyMealViewModel>(
        builder: (_, vm, __) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: vm.meals.map((m) {
              return Card(
                child: ListTile(
                  title: Text(m.name),
                  subtitle: Text("${m.totalKcal.toStringAsFixed(0)} kcal"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
