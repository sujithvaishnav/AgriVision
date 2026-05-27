import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'weatherApiService.dart';

Future<dynamic> diseaseDescription(String disease_name) async {
  final String baseUrl =
      "https://9b81-2409-40f0-6-65a5-b975-3ad1-30c5-3441.ngrok-free.app";

  try {
    final response = await http.post(
      Uri.parse("$baseUrl/diseaseDescription"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"disease_name": disease_name}),
    );

    print("\n\nStatus code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Could be JSON or plain text
    } else {
      throw Exception("Failed to get Disease Description: ${response.body}");
    }
  } catch (e) {
    print("Error in getting Disease Description: $e");
    throw Exception("Error Fetching Disease Description: $e");
  }
}

Future<dynamic> fertilizerRecommendation(double n, double p, double ph,
    double k, String crop, bool _ismanual) async {
  final String baseUrl =
      "https://9b81-2409-40f0-6-65a5-b975-3ad1-30c5-3441.ngrok-free.app";
  Position position = await getUserLocation();

  try {
    final response = await http.post(
      Uri.parse("$baseUrl/fertilizersRecommendation"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "_ismanual": _ismanual,
        "manual_data": {"N": n, "P": p, "K": k, "pH": ph},
        "crop": crop
      }),
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

Future<dynamic> cropRecommendation(
    double n, double p, double ph, double k, bool _ismanual) async {
  final String baseUrl =
      "https://9b81-2409-40f0-6-65a5-b975-3ad1-30c5-3441.ngrok-free.app";
  Position position = await getUserLocation();

  Map<String, dynamic> weatherdetails = await predictTodayForecast(position);

  try {
    final response = await http.post(
      Uri.parse("$baseUrl/cropRecommendation"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "_ismanual": _ismanual,
        "manual_data": {
          "N": n,
          "P": p,
          "K": k,
          "pH": ph,
          "Temperature (°C)": weatherdetails['today']['Temperature (°C)'],
          "Humidity (%)": weatherdetails['today']['Humidity (%)'],
          "Rainfall (mm)": weatherdetails['today']['Rainfall (mm)']
        },
      }),
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
