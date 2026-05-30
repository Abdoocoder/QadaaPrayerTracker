import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _supabaseUrl = 'https://tutkrytcukbirqauslgc.supabase.co';
  static const _anonKey = 'sb_publishable_LjVPgNo0FWAzca2cswKFHg_twaOeWAE';

  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  bool _initialized = false;

  GoTrueClient get auth => Supabase.instance.client.auth;
  SupabaseClient get client => Supabase.instance.client;

  Future<void> init() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _anonKey,
    );
    _initialized = true;
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

  static String formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
