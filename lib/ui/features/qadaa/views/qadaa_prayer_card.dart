import 'package:flutter/material.dart';
import '../../../../domain/models/prayer_name.dart';
import '../../../../domain/models/qadaa_progress.dart';
import '../../../../theme/app_theme.dart';

class QadaaPrayerCard extends StatelessWidget {
  final PrayerName prayerName;
  final QadaaProgress progress;
  final int index;
  final VoidCallback onLog;

  const QadaaPrayerCard({
    super.key,
    required this.prayerName,
    required this.progress,
    required this.index,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.prayerColor(index);
    final pct = progress.percentage.round();
    final isComplete = progress.isComplete;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: isComplete ? null : onLog,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Expanded(
                    child: Text(
                      prayerName.arName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isComplete)
                    const Icon(Icons.check_circle, size: 20, color: AppTheme.primary),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.totalMissed > 0
                      ? progress.completed / progress.totalMissed
                      : 0,
                  minHeight: 8,
                  backgroundColor: AppTheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? AppTheme.primary : color,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isComplete ? AppTheme.primary : AppTheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${progress.remaining}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
