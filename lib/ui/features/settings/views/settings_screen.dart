import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../di/locator.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/prayer_time_service.dart';
import '../../home/views/home_screen.dart';
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
                padding: EdgeInsetsDirectional.only(
                  start: AppTheme.spaceSm, end: AppTheme.spaceSm,
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
                  overflow: TextOverflow.ellipsis,
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
              const _GroupHeader(title: 'الحساب'),
              const SizedBox(height: AppTheme.spaceMd),
              if (vm.isSignedIn) ...[
                _SettingsInfo(
                  icon: Icons.person_rounded,
                  title: vm.userEmail ?? '',
                  subtitle: 'مسجل الدخول',
                ),
                GestureDetector(
                  onTap: () => _signOut(context),
                  child: _SettingsNav(
                    icon: Icons.logout_rounded,
                    title: 'تسجيل الخروج',
                    subtitle: 'تسجيل الخروج من حسابك',
                    isDestructive: true,
                  ),
                ),
              ] else ...[
                _SettingsNav(
                  icon: Icons.login_rounded,
                  title: 'تسجيل الدخول',
                  subtitle: 'سجل دخولك لمزامنة بياناتك',
                  onTap: () => _showAuthDialog(context, isSignUp: false),
                ),
                _SettingsNav(
                  icon: Icons.person_add_rounded,
                  title: 'إنشاء حساب',
                  subtitle: 'أنشئ حساباً لمزامنة بياناتك',
                  onTap: () => _showAuthDialog(context, isSignUp: true),
                ),
              ],
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
              _SettingsNav(
                icon: Icons.dark_mode_rounded,
                title: 'المظهر',
                subtitle: _themeLabel(vm.themeMode),
                onTap: () => _showThemeDialog(context),
              ),
              _SettingsNav(
                icon: Icons.history_rounded,
                title: 'سنوات القضاء',
                subtitle: '${vm.qadaaYears} سنوات',
                onTap: () => _showQadaaYearsDialog(context),
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
                  overflow: TextOverflow.ellipsis,
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
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'المدينة / City'),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TextField(
              controller: countryCtrl,
              maxLength: 100,
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

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark: return 'داكن';
      case ThemeMode.system: return 'تلقائي';
      default: return 'فاتح';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('المظهر', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
        children: [
          SimpleDialogOption(
            onPressed: () { vm.setThemeMode(ThemeMode.light); Navigator.pop(ctx); },
            child: Text('فاتح', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: vm.themeMode == ThemeMode.light ? FontWeight.w700 : FontWeight.w400)),
          ),
          SimpleDialogOption(
            onPressed: () { vm.setThemeMode(ThemeMode.dark); Navigator.pop(ctx); },
            child: Text('داكن', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: vm.themeMode == ThemeMode.dark ? FontWeight.w700 : FontWeight.w400)),
          ),
          SimpleDialogOption(
            onPressed: () { vm.setThemeMode(ThemeMode.system); Navigator.pop(ctx); },
            child: Text('تلقائي', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: vm.themeMode == ThemeMode.system ? FontWeight.w700 : FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  void _showQadaaYearsDialog(BuildContext context) {
    final controller = TextEditingController(text: vm.qadaaYears.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سنوات القضاء', style: TextStyle(fontFamily: 'Plus Jakarta Sans')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('عدد السنوات التي تركت فيها الصلاة:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14)),
            const SizedBox(height: AppTheme.spaceMd),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 3,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'مثال: 3',
                filled: true,
                fillColor: AppTheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceLg,
                  vertical: AppTheme.spaceLg,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
              Text(
                'سيتم إعادة حساب جميع الإحصائيات',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: AppTheme.outline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final years = int.tryParse(controller.text.trim());
              if (years != null && years > 0) {
                vm.setQadaaYears(years);
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
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Qadaa Prayer Tracker - بيانات الصلوات',
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('خطأ في التصدير: $e')),
      );
    }
  }

  void _showAuthDialog(BuildContext context, {required bool isSignUp}) {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSignUp ? 'إنشاء حساب' : 'تسجيل الدخول', style: const TextStyle(fontFamily: 'Plus Jakarta Sans')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني / Email'),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور / Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              final password = passwordCtrl.text.trim();
              if (email.isEmpty || password.isEmpty) return;
              String? error;
              if (isSignUp) {
                error = await vm.signUp(email, password);
              } else {
                error = await vm.signIn(email, password);
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (!context.mounted) return;
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              } else if (!isSignUp) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const HomeScreen(),
                    transitionsBuilder: (context, anim, _, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: AppTheme.durationSlow,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم إرسال رابط التفعيل إلى بريدك الإلكتروني')),
                );
              }
            },
            child: Text(isSignUp ? 'إنشاء حساب' : 'تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final error = await vm.signOut();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
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
        overflow: TextOverflow.ellipsis,
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
        title: Text(widget.title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onSurface), overflow: TextOverflow.ellipsis),
        subtitle: Text(widget.subtitle, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
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

class _SettingsInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
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
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onSurface), overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
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
        title: Text(title, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w600, color: isDestructive ? AppTheme.error : AppTheme.onSurface), overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.chevron_left_rounded, color: AppTheme.outline.withValues(alpha: 0.5)),
        onTap: onTap,
      ),
    );
  }
}
