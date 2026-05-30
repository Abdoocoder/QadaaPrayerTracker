import 'package:flutter/material.dart';
import '../../../../di/locator.dart';
import '../../../../theme/app_theme.dart';
import '../../../../domain/models/prayer_name.dart';
import '../../../core/widgets/stat_card.dart';
import '../view_models/stats_view_model.dart';
import 'weekly_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final vm = sl<StatsViewModel>();

  @override
  void initState() { super.initState(); vm.load(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: vm, builder: (context, _) {
      if (vm.loading) return const SafeArea(child: Center(child: CircularProgressIndicator()));
      if (vm.error != null) {
        return SafeArea(child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceXxl),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.outline.withValues(alpha: 0.5)),
              const SizedBox(height: AppTheme.spaceLg),
              const Text('تعذر تحميل الإحصائيات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface), overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppTheme.spaceSm),
              Text(vm.error!, style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppTheme.spaceXl),
              FilledButton.icon(icon: const Icon(Icons.refresh, size: 18), label: const Text('إعادة المحاولة'), onPressed: vm.load),
            ]),
          ),
        ));
      }
      final agg = vm.agg;
      final dist = vm.dist;
      final weekLogs = vm.weekLogs;
      if (agg == null || dist == null || weekLogs == null) {
        return const SafeArea(child: Center(child: Text('لا توجد بيانات', style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant), overflow: TextOverflow.ellipsis)));
      }
      return SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsetsDirectional.only(start: AppTheme.spaceSm, end: AppTheme.spaceSm, top: AppTheme.spaceMd), child: Text('الإحصائيات', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.onSurface, letterSpacing: -0.3), overflow: TextOverflow.ellipsis)),
          const SizedBox(height: AppTheme.spaceXl),
          Wrap(spacing: AppTheme.spaceMd, runSpacing: AppTheme.spaceMd, children: [
            StatCard(label: 'هذا الأسبوع', value: '${agg['week_done']}', sub: 'صلاة مقضية', icon: Icons.date_range_rounded, color: AppTheme.primary),
            StatCard(label: 'هذا الشهر', value: '${agg['month_done']}', sub: 'صلاة مقضية', icon: Icons.calendar_month_rounded, color: AppTheme.secondary),
            StatCard(label: 'الإجمالي', value: '${agg['all_done']}', sub: 'صلاة مقضية', icon: Icons.assignment_turned_in_rounded, color: AppTheme.tertiary),
            StatCard(label: 'معدل الإنجاز', value: _pct(agg['all_done'] ?? 0, agg['all_total'] ?? 0), sub: 'نسبة التقدم', icon: Icons.trending_up_rounded, color: AppTheme.primaryFixedDim),
          ]),
          const SizedBox(height: AppTheme.spaceXxl),
          const Padding(padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceSm), child: Text('توزيع الصلوات', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurface, letterSpacing: -0.2), overflow: TextOverflow.ellipsis)),
          const SizedBox(height: AppTheme.spaceLg),
          _DistributionSection(dist: dist),
          const SizedBox(height: AppTheme.spaceXxl),
          const Padding(padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceSm), child: Text('آخر ٧ أيام', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurface, letterSpacing: -0.2), overflow: TextOverflow.ellipsis)),
          const SizedBox(height: AppTheme.spaceLg),
          WeeklyChart(weekLogs: weekLogs),
        ]),
      ));
    });
  }

  String _pct(int done, int total) => total == 0 ? '0%' : '${(done / total * 100).round()}%';
}

class _DistributionSection extends StatelessWidget {
  final Map<String, int> dist;
  const _DistributionSection({required this.dist});

  @override
  Widget build(BuildContext context) {
    final maxVal = dist.values.fold<int>(1, (a, b) => a > b ? a : b);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          children: allPrayers.asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            final done = dist[p.name] ?? 0;
            final ratio = maxVal > 0 ? done / maxVal : 0.0;
            final barColor = AppTheme.prayerColor(i);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: barColor, shape: BoxShape.circle)),
                    const SizedBox(width: AppTheme.spaceSm),
                    Text(p.arName, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurface), overflow: TextOverflow.ellipsis),
                  ]),
                  Text('$done', style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                ]),
                const SizedBox(height: AppTheme.spaceXs),
                ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: ratio, backgroundColor: AppTheme.surfaceContainerHigh, valueColor: AlwaysStoppedAnimation<Color>(barColor), minHeight: 6)),
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }
}
