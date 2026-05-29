import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../domain/models/day_log.dart';

class WeeklyChart extends StatelessWidget {
  final List<DayLog> weekLogs;
  const WeeklyChart({super.key, required this.weekLogs});

  @override
  Widget build(BuildContext context) {
    final days = ['س', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    final maxVal = weekLogs.map((l) => l.completed).fold<int>(1, (a, b) => a > b ? a : b);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(weekLogs.length, (i) {
              final h = maxVal > 0 ? (weekLogs[i].completed / maxVal) * 110 : 0.0;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: h.clamp(0, 110),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppTheme.primary, AppTheme.primaryFixedDim],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSm)),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(days[i], style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
