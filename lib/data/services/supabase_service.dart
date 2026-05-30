import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://tutkrytcukbirqauslgc.supabase.co',
  );
  static const _anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_LjVPgNo0FWAzca2cswKFHg_twaOeWAE',
  );

  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  bool _initialized = false;
  final List<VoidCallback> _authListeners = [];

  GoTrueClient get auth => Supabase.instance.client.auth;
  SupabaseClient get client => Supabase.instance.client;

  void addAuthListener(VoidCallback cb) => _authListeners.add(cb);
  void removeAuthListener(VoidCallback cb) => _authListeners.remove(cb);

  Future<void> init() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _anonKey,
    );
    _initialized = true;

    auth.onAuthStateChange.listen((_) {
      for (final cb in _authListeners) {
        cb();
      }
    });
  }

  bool get isSignedIn => auth.currentUser != null;
  String? get userId => auth.currentUser?.id;
  String? get userEmail => auth.currentUser?.email;

  Future<AuthResponse> signUp(String email, String password) =>
      auth.signUp(email: email, password: password);

  Future<AuthResponse> signIn(String email, String password) =>
      auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signInAnonymously() =>
      auth.signInAnonymously();

  Future<void> signOut() => auth.signOut();

  static String friendlyError(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('email not confirmed') || msg.contains('email_not_confirmed')) {
      return 'يرجى تفعيل حسابك من رابط التأكيد المرسل إلى بريدك الإلكتروني';
    }
    if (msg.contains('invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('user already registered')) {
      return 'هذا البريد الإلكتروني مسجل مسبقاً';
    }
    if (msg.contains('password should be at least 6')) {
      return 'كلمة المرور يجب أن تكون ٦ أحرف على الأقل';
    }
    if (msg.contains('network') || msg.contains('timeout') || msg.contains('failed host')) {
      return 'خطأ في الاتصال بالشبكة، تحقق من اتصالك وحاول مرة أخرى';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'طلبات كثيرة جداً، حاول بعد قليل';
    }
    return 'خطأ: $error';
  }

  Future<Map<String, dynamic>?> fetchPrayerTimes({
    required String date,
    String? lat,
    String? lng,
    String? method,
  }) async {
    try {
      final resp = await client.functions.invoke(
        'fetch-prayer-times',
        method: HttpMethod.get,
        queryParameters: {
          'date': date,
          'lat': ?lat,
          'lng': ?lng,
          'method': ?method,
        },
      );
      if (resp.data != null) {
        return resp.data as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Supabase fetchPrayerTimes failed: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPrayerLogs({
    DateTime? from, DateTime? to, int? limit,
  }) async {
    var query = client.from('qadaa.prayer_logs').select();

    if (from != null) query = query.gte('date', SupabaseService.formatDate(from));
    if (to != null) query = query.lte('date', SupabaseService.formatDate(to));

    var transform = query.order('date', ascending: false);
    if (limit != null) transform = transform.limit(limit);

    final resp = await transform;
    return (resp as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> upsertPrayerLog({
    required String date,
    required String prayerName,
    required bool completed,
  }) async {
    await client.from('qadaa.prayer_logs').upsert({
      'user_id': userId,
      'date': date,
      'prayer_name': prayerName,
      'completed': completed,
    }, onConflict: 'user_id,date,prayer_name');
  }

  Future<void> upsertSetting(String key, String value) async {
    if (userId == null) return;
    await client.from('qadaa.settings').upsert({
      'user_id': userId,
      'key': key,
      'value': value,
    }, onConflict: 'user_id,key');
  }

  Future<String?> getSetting(String key) async {
    if (userId == null) return null;
    final resp = await client
        .from('qadaa.settings')
        .select('value')
        .eq('user_id', userId!)
        .eq('key', key)
        .maybeSingle();
    return resp?['value'] as String?;
  }

  Future<void> upsertQadaaProgress({
    required String prayerName,
    required int totalMissed,
    required int completed,
  }) async {
    if (userId == null) return;
    await client.from('qadaa.qadaa_progress').upsert({
      'user_id': userId,
      'prayer_name': prayerName,
      'total_missed': totalMissed,
      'completed': completed,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,prayer_name');
  }

  Future<Map<String, dynamic>?> getQadaaProgress(String prayerName) async {
    if (userId == null) return null;
    final resp = await client
        .from('qadaa.qadaa_progress')
        .select()
        .eq('user_id', userId!)
        .eq('prayer_name', prayerName)
        .maybeSingle();
    return resp;
  }

  Future<void> upsertQadaaLog({
    required String prayerName,
    required int count,
    required String createdAt,
  }) async {
    if (userId == null) return;
    await client.from('qadaa.qadaa_logs').insert({
      'user_id': userId,
      'prayer_name': prayerName,
      'count': count,
      'created_at': createdAt,
    });
  }

  Future<List<Map<String, dynamic>>> getQadaaLogs({int? limit}) async {
    if (userId == null) return [];
    var query = client
        .from('qadaa.qadaa_logs')
        .select()
        .eq('user_id', userId!)
        .order('created_at', ascending: false);
    if (limit != null) query = query.limit(limit);
    final resp = await query;
    return (resp as List<dynamic>).cast<Map<String, dynamic>>();
  }

  static String formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
