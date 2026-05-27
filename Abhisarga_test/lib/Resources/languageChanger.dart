import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _selectedLocale = const Locale('en', 'US');

  Locale get selectedLocale => _selectedLocale;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    String? countryCode = prefs.getString('country_code');

    if (languageCode != null && countryCode != null) {
      _selectedLocale = Locale(languageCode, countryCode);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Locale newLocale) async {
    _selectedLocale = newLocale;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    await prefs.setString('country_code', newLocale.countryCode ?? '');
  }

  static final List<Map<String, dynamic>> supportedLanguages = [
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': 'हिन्दी (Hindi)', 'locale': const Locale('hi', 'IN')},
    {'name': 'తెలుగు (Telugu)', 'locale': const Locale('te', 'IN')},
    {'name': 'தமிழ் (Tamil)', 'locale': const Locale('ta', 'IN')},
    {'name': 'ਪੰਜਾਬੀ (Punjabi)', 'locale': const Locale('pa', 'IN')},
  ];

  static List<Locale> get supportedLocales =>
      supportedLanguages.map((lang) => lang['locale'] as Locale).toList();

  Future<dynamic> translate(String description) async {
    final String baseUrl =
        "https://9b81-2409-40f0-6-65a5-b975-3ad1-30c5-3441.ngrok-free.app";

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/translate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {
            "description": description,
            "language": _selectedLocale.languageCode
          },
        ),
      );

      print("\n\nStatus code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to get Recommendation: ${response.body}");
      }
    } catch (e) {
      print("Error in getting Recommendation: $e");
      throw Exception("Error Fetching Recommendation: $e");
    }
  }
}
