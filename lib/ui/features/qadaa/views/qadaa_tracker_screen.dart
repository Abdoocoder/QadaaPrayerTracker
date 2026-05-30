import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/qadaa_log_model.dart';
import '../../../../di/locator.dart';
import '../../../../domain/models/prayer_name.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../data/services/qadaa_service.dart';
import '../../../../theme/app_theme.dart';
import 'qadaa_prayer_card.dart';

class QadaaTrackerScreen extends StatefulWidget {
  const QadaaTrackerScreen({super.key});

  @override
  State<QadaaTrackerScreen> createState() => _QadaaTrackerScreenState();
}

class _QadaaTrackerScreenState extends State<QadaaTrackerScreen> {
  final _qadaaService = sl<QadaaService>();

  int get _years => _qadaaService.getYears();

  void _showLogDialog(PrayerName prayer) {
    final controller = TextEditingController();
    String? validationError;
    showDialog(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
            title: Text(prayer.arName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 5,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: loc.qadaaEnterCount,
                    errorText: validationError,
                  ),
                  onChanged: (_) {
                    if (validationError != null) {
                      setDialogState(() => validationError = null);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(ctx)!.resetCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = controller.text.trim();
                  final count = int.tryParse(text);
                  if (count == null || count <= 0) {
                    setDialogState(() {
                      validationError = loc.qadaaEnterValidNumber;
                    });
                    return;
                  }
                  setState(() {
                    _qadaaService.addLog(prayer.name, count);
                  });
                  Navigator.pop(ctx);
                },
                child: Text(loc.qadaaLogButton),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_years <= 0) {
      return const Center(
        child: Text(
          'حدد سنوات الصلوات الفائتة من الإعدادات',
          style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final loc = AppLocalizations.of(context)!;
    final allProgress = _qadaaService.getAllProgress();
    final logs = _qadaaService.getLogs();
    final grandTotal = _qadaaService.getGrandTotal();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.qadaaTrackerTitle,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Wrap(
              spacing: AppTheme.spaceMd,
              runSpacing: AppTheme.spaceMd,
              children: allProgress.asMap().entries.map((e) {
                final i = e.key;
                final p = e.value;
                final prayer = PrayerName.values[i];
                return SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          AppTheme.spaceLg * 2 -
                          AppTheme.spaceMd) /
                      2,
                  child: QadaaPrayerCard(
                    prayerName: prayer,
                    progress: p,
                    index: i,
                    onLog: () => _showLogDialog(prayer),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            Center(
              child: Text(
                loc.qadaaTotalMadeUp(grandTotal),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (logs.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceXxl),
              Text(
                loc.qadaaRecentActivity,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              ...logs.take(20).map((log) => _LogTile(log: log)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final QadaaLogModel log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final prayer = PrayerName.values.firstWhere(
      (p) => p.name == log.prayerName,
      orElse: () => PrayerName.fajr,
    );
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceLg,
            vertical: AppTheme.spaceMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  log.count == 1
                      ? loc.qadaaPrayerMadeUp(prayer.arName, log.count)
                      : loc.qadaaPrayerMadeUp(prayer.arName, log.count),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: AppTheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTime(log.createdAt),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: AppTheme.outline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }
}
