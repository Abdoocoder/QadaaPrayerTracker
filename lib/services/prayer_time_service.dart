import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/prayer_times_model.dart';

class PrayerTimeService {
  static const _baseUrl = 'https://api.aladhan.com/v1/timingsByCity';

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

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch prayer times: ${resp.statusCode}');
    }

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return PrayerTimesModel.fromJson(body['data'] as Map<String, dynamic>, dateStr);
  }
}
