import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/prayer_times_model.dart';

class PrayerTimeService {
  static const _baseUrl = 'https://api.aladhan.com/v1/timingsByCity';
  static const _timeout = Duration(seconds: 15);

  String city = 'Amman';
  String country = 'Jordan';
  int method = 3;

  static const calculationMethods = {
    0: 'Shia Ithna Ashari',
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America',
    3: 'Muslim World League',
    4: 'Umm Al-Qura University, Makkah',
    5: 'Egyptian General Authority of Survey',
    7: 'Institute of Geophysics, University of Tehran',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    12: 'Majlis Ugama Islam Singapura',
    14: 'Diyanet İşleri Başkanlığı (Turkey)',
    15: 'Tunisia',
    16: 'Algeria',
    17: 'Morocco',
    18: 'Comite Israelite de Paris',
    20: 'Islamic Affairs Department (Brunei)',
    21: 'Ministry of Religious Affairs (Indonesia)',
  };

  Future<PrayerTimesModel> fetchTimes(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final url = '$_baseUrl/$dateStr?city=$city&country=$country&method=$method';

    try {
      final resp = await http.get(Uri.parse(url)).timeout(_timeout);
      if (resp.statusCode != 200) {
        throw Exception('(${resp.statusCode})');
      }

      final decoded = jsonDecode(resp.body);
      final data = (decoded as Map<String, dynamic>)['data'];
      if (data == null) {
        throw Exception('API response missing data field');
      }
      return PrayerTimesModel.fromJson(data as Map<String, dynamic>, dateStr);
    } on FormatException {
      throw Exception('Invalid server response');
    } on http.ClientException {
      throw Exception('Network error - check your connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    }
  }
}
