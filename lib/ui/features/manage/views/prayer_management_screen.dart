import 'package:flutter/material.dart';
import '../../../../di/locator.dart';
import '../../../../theme/app_theme.dart';
import '../../../../domain/models/prayer_name.dart';
import '../view_models/manage_view_model.dart';
import 'date_strip.dart';
import 'toggle_tile.dart';

class PrayerManagementScreen extends StatefulWidget {
  const PrayerManagementScreen({super.key});
  @override
  State<PrayerManagementScreen> createState() => _PrayerManagementScreenState();
}

class _PrayerManagementScreenState extends State<PrayerManagementScreen> {
  final vm = sl<ManageViewModel>();

  @override
  void initState() { super.initState(); vm.loadDay(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: vm, builder: (context, _) {
      return Scaffold(
        appBar: AppBar(title: const Text('إدارة الصلوات', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 19, fontWeight: FontWeight.w700))),
        body: ListView(padding: const EdgeInsets.all(AppTheme.spaceLg), children: [
          DateStrip(selected: vm.selectedDay, dates: vm.dates, onSelect: (i) => vm.selectDay(i)),
          const SizedBox(height: AppTheme.spaceXl),
          Text('اختر الصلوات التي قضيتها', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8))),
          const SizedBox(height: AppTheme.spaceLg),
          if (vm.loading) const Center(child: Padding(padding: EdgeInsets.all(AppTheme.spaceXxl), child: CircularProgressIndicator()))
          else ...allPrayers.map((p) => ToggleTile(
            key: ValueKey('prayer_${vm.selectedDay}_${p.name}'),
            name: p.arName, time: vm.times?.forPrayer(p) ?? '--:--',
            completed: vm.dayLog?.isCompleted(p) ?? false,
            onToggle: () => vm.toggle(p),
          )),
          const SizedBox(height: AppTheme.spaceXxl),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('حفظ'))),
          const SizedBox(height: AppTheme.spaceXl),
        ]),
      );
    });
  }
}
