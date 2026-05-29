import 'package:flutter/material.dart';
import '../../../../di/locator.dart';
import '../../../../domain/models/day_log.dart';
import '../../../../domain/models/prayer_name.dart';
import '../../../../domain/models/prayer_times.dart';
import '../../../../theme/app_theme.dart';
import '../../../core/widgets/section_header.dart';
import '../../manage/views/prayer_management_screen.dart';
import '../view_models/home_view_model.dart';
import 'greeting_header.dart';
import 'hero_stats_card.dart';
import 'reminder_list.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final vm = sl<HomeViewModel>();

  @override
  void initState() { super.initState(); vm.load(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: vm, builder: (context, _) {
      if (vm.loading) return const SafeArea(child: Center(child: CircularProgressIndicator()));
      return SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const GreetingHeader(),
          const SizedBox(height: AppTheme.spaceXl),
          HeroStatsCard(today: vm.today!, agg: vm.agg!),
          const SizedBox(height: AppTheme.spaceXxl),
          SectionHeader(title: 'صلوات اليوم', action: 'إدارة', onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerManagementScreen()))),
          const SizedBox(height: AppTheme.spaceLg),
          _PrayerGrid(today: vm.today!, times: vm.times!),
          const SizedBox(height: AppTheme.spaceXxl),
          SectionHeader(title: 'تذكيرات', action: 'عرض الكل'),
          const SizedBox(height: AppTheme.spaceLg),
          ReminderList(today: vm.today!),
          const SizedBox(height: AppTheme.spaceXxl),
        ]),
      ));
    });
  }
}

class _PrayerGrid extends StatelessWidget {
  final DayLog today;
  final PrayerTimes times;
  const _PrayerGrid({required this.today, required this.times});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spaceMd,
      runSpacing: AppTheme.spaceMd,
      children: allPrayers.map((p) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width -
                  AppTheme.spaceLg * 2 -
                  AppTheme.spaceMd) /
              2,
          child: _PrayerCard(
            name: p,
            completed: today.isCompleted(p),
            time: times.forPrayer(p),
          ),
        );
      }).toList(),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerName name;
  final bool completed;
  final String time;
  const _PrayerCard({required this.name, required this.completed, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppTheme.durationFast,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: completed ? AppTheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: completed ? AppTheme.primary : AppTheme.outline,
                    width: 2,
                  ),
                ),
                child: completed
                    ? const Icon(Icons.check, size: 16, color: AppTheme.onPrimary)
                    : null,
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.arName,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: completed
                            ? AppTheme.onSurfaceVariant
                            : AppTheme.onSurface,
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
