import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../di/locator.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/prayer_time_service.dart';
import '../view_models/settings_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final vm = sl<SettingsViewModel>();

  @override
  void initState() { super.initState(); vm.loadSettings(); }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: vm, builder: (context, _) {
      if (vm.loading) return const SafeArea(child: Center(child: CircularProgressIndicator()));
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(
                  left: AppTheme.spaceSm, right: AppTheme.spaceSm,
                  top: AppTheme.spaceMd,
                ),
                child: Text(
                  'التنبيهات والإعدادات',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceXxl),
              const _GroupHeader(title: 'التنبيهات'),
              const SizedBox(height: AppTheme.spaceMd),
              _SettingsSwitch(
                icon: Icons.notifications_active_rounded,
                title: 'تذكير بالصلوات القادئة',
                subtitle: 'تنبيه يومي لأوقات القضاء',
                value: vm.notificationsEnabled,
                onChanged: (v) => vm.toggleNotifications(v),
              ),
              _SettingsSwitch(
                icon: Icons.vibration_rounded,
                title: 'اهتزاز',
                subtitle: 'تفعيل الاهتزاز مع التنبيهات',
                value: vm.vibrationEnabled,
                onChanged: (v) => vm.toggleVibration(v),
              ),
              const SizedBox(height: AppTheme.spaceXxl),
              const _GroupHeader(title: 'الإعدادات العامة'),
              const SizedBox(height: AppTheme.spaceMd),
              _SettingsNav(
                icon: Icons.language_rounded,
                title: 'اللغة',
                subtitle: vm.localeCode == 'en' ? 'English' : 'العربية',
                onTap: () => _showLanguageDialog(context),
              ),
              _SettingsNav(
                icon: Icons.calendar_month_rounded,
                title: 'حساب التاريخ',
                subtitle: vm.methodName,
                onTap: () => _showMethodDialog(context),
              ),
              _SettingsNav(
                icon: Icons.location_on_rounded,
                title: 'موقعي',
                subtitle: vm.locationDisplay,
                onTap: () => _showLocationDialog(context),
              ),
              const SizedBox(height: AppTheme.spaceXxl),
              const _GroupHeader(title: 'البيانات'),
              const SizedBox(height: AppTheme.spaceMd),
              _SettingsNav(
                icon: Icons.download_rounded,
                title: 'تصدير البيانات',
                subtitle: 'احتفظ بنسخة من إحصائياتك',
                onTap: () => _showExportDialog(context),
              ),
              GestureDetector(
                onTap: () => _resetData(context),
                child: _SettingsNav(
                  icon: Icons.delete_sweep_rounded,
                  title: 'إعادة تعيين',
                  subtitle: 'مسح جميع البيانات والبدء من جديد',
                  isDestructive: true,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXl * 2),
              Center(
                child: Text(
                  'Qadaa Prayer Tracker  ·  1.0.0',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.outline.withValues(alpha: 0.7),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceXl),
            ],
          ),
        ),
      );
    });
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('اللغة / Language', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
        children: [
          SimpleDialogOption(
            onPressed: () { vm.setLocale('ar'); Navigator.pop(ctx); },
            child: Text('العربية', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: vm.localeCode == 'ar' ? FontWeight.w700 : FontWeight.w400)),
          ),
          SimpleDialogOption(
            onPressed: () { vm.setLocale('en'); Navigator.pop(ctx); },
            child: Text('English', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: vm.localeCode == 'en' ? FontWeight.w700 : FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  void _showMethodDialog(BuildContext context) {
    final methods = PrayerTimeService.calculationMethods.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('طريقة حساب الوقت', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
        children: methods.map((e) => SimpleDialogOption(
          onPressed: () { vm.setMethod(e.key); Navigator.pop(ctx); },
          child: Text(e.value, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: vm.method == e.key ? FontWeight.w700 : FontWeight.w400)),
        )).toList(),
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    final cityCtrl = TextEditingController(text: vm.city);
    final countryCtrl = TextEditingController(text: vm.country);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الموقع', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(labelText: 'المدينة / City'),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TextField(
              controller: countryCtrl,
              decoration: const InputDecoration(labelText: 'الدولة / Country'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (cityCtrl.text.trim().isNotEmpty && countryCtrl.text.trim().isNotEmpty) {
                vm.setLocation(cityCtrl.text.trim(), countryCtrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('تصدير البيانات', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
        children: [
          SimpleDialogOption(
            onPressed: () { Navigator.pop(ctx); _export('csv'); },
            child: const Text('CSV', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16)),
          ),
          SimpleDialogOption(
            onPressed: () { Navigator.pop(ctx); _export('json'); },
            child: const Text('JSON', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _export(String format) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final content = format == 'csv' ? await vm.exportCsv() : await vm.exportJson();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/prayer_logs.$format');
      await file.writeAsString(content);
      if (!context.mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Qadaa Prayer Tracker - بيانات الصلوات',
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('خطأ في التصدير: $e')),
      );
    }
  }

  Future<void> _resetData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تعيين البيانات', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
        content: const Text('هل أنت متأكد؟ سيتم مسح جميع بيانات الصلوات المسجلة.', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تأكيد', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirm != true) return;
    await vm.resetData();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم مسح جميع البيانات')),
      );
    }
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;
  const _GroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.onSurfaceVariant.withValues(alpha: 0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  State<_SettingsSwitch> createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends State<_SettingsSwitch> {
  late bool _value;

  @override
  void initState() { super.initState(); _value = widget.value; }

  @override
  void didUpdateWidget(_SettingsSwitch old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: 2),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
          child: Icon(widget.icon, color: AppTheme.primary, size: 20),
        ),
        title: Text(widget.title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
        subtitle: Text(widget.subtitle, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.onSurfaceVariant)),
        trailing: Switch(
          value: _value,
          activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
          activeThumbColor: AppTheme.primary,
          onChanged: (v) { setState(() => _value = v); widget.onChanged?.call(v); },
        ),
      ),
    );
  }
}

class _SettingsNav extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsNav({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: 2),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isDestructive ? AppTheme.error.withValues(alpha: 0.08) : AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: isDestructive ? AppTheme.error : AppTheme.primary, size: 20),
        ),
        title: Text(title, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: isDestructive ? AppTheme.error : AppTheme.onSurface)),
        subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.onSurfaceVariant)),
        trailing: Icon(Icons.chevron_left_rounded, color: AppTheme.outline.withValues(alpha: 0.5)),
        onTap: onTap,
      ),
    );
  }
}
