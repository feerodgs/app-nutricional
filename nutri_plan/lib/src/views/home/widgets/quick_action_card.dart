import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const QuickActionCard(
      {super.key, required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 90,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon),
              const Spacer(),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
}
