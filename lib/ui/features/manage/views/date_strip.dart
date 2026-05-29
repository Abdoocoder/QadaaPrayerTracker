import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class DateStrip extends StatelessWidget {
  final int selected;
  final List<DateTime> dates;
  final ValueChanged<int> onSelect;

  const DateStrip({super.key, required this.selected, required this.dates, required this.onSelect});

  String _label(int i) {
    if (i == 0) return 'اليوم';
    if (i == 1) return 'أمس';
    final weekdays = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return weekdays[dates[i].weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTheme.spaceSm),
        itemBuilder: (_, i) {
          final sel = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: AppTheme.durationFast,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primary : AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: sel ? AppTheme.primary : AppTheme.outlineVariant,
                  width: sel ? 0 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _label(i),
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: sel ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
