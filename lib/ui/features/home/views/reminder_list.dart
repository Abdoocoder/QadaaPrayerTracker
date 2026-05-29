import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../domain/models/day_log.dart';
import '../../../../domain/models/prayer_name.dart';
import '../../manage/views/prayer_management_screen.dart';

class ReminderList extends StatelessWidget {
  final DayLog today;
  const ReminderList({super.key, required this.today});

  @override
  Widget build(BuildContext context) {
    final undone = allPrayers.where((p) => !today.isCompleted(p)).toList();
    if (undone.isEmpty) {
      return const Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spaceLg),
          child: Text(
            'جميع صلوات اليوم مقضية، أحسنت!',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: undone.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceSm,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.secondary, size: 20,
                ),
              ),
              title: Text(
                'صلاة ${p.arName}',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              subtitle: const Text(
                'لم تقض هذه الصلاة بعد',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              trailing: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrayerManagementScreen(),
                    ),
                  );
                },
                child: const Text('قضاء'),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
