import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const StatCard({super.key, required this.label, required this.value, required this.sub, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - AppTheme.spaceLg * 2 - AppTheme.spaceMd) / 2;
    return SizedBox(width: w, child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppTheme.radiusSm)), child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: AppTheme.spaceMd),
          Text(value, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 26, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w400, color: AppTheme.outline)),
        ]),
      ),
    ));
  }
}
