import 'package:flutter/material.dart';

class KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final double progress; // 0..1
  final String? subtitle;

  const KpiTile({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: p),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(subtitle ?? ''),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
    );
  }
}
