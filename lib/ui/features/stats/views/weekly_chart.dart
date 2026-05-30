import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../domain/models/day_log.dart';

class WeeklyChart extends StatefulWidget {
  final List<DayLog> weekLogs;
  const WeeklyChart({super.key, required this.weekLogs});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(WeeklyChart old) {
    super.didUpdateWidget(old);
    if (widget.weekLogs != old.weekLogs) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = ['س', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    final maxVal =
        widget.weekLogs.map((l) => l.completed).fold<int>(1, (a, b) => a > b ? a : b);
    final t = _controller.value;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.weekLogs.length, (i) {
              final rawH = maxVal > 0
                  ? (widget.weekLogs[i].completed / maxVal) * 110
                  : 0.0;
              final staggerStart = i * 0.1;
              final progress = ((t - staggerStart) / 0.5).clamp(0.0, 1.0);
              final eased = AppTheme.easeOutStrong.transform(progress);
              final h = rawH * eased;
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
                          colors: [
                            AppTheme.primary,
                            AppTheme.primaryFixedDim,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusSm),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      days[i],
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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
