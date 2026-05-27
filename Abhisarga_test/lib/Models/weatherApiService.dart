import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

Future<Position> getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  // Check for location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied.');
  }

  // Get the current location
  return await Geolocator.getCurrentPosition();
}

Future<Map<String, dynamic>> predictForecast(Position position) async {
  final String baseUrl =
      "https://9b81-2409-40f0-6-65a5-b975-3ad1-30c5-3441.ngrok-free.app";

  try {
    final response = await http.post(
      Uri.parse("$baseUrl/predictforecastWeather"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"latitude": position.latitude, "longitude": position.longitude}),
    );

    print("\n\nStatus code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get Weather Data: ${response.body}");
    }
  } catch (e) {
    print("Error in getting Weather Data: $e");
    throw Exception("Error Weather Data: $e");
  }
}

Future<Map<String, dynamic>> predictTodayForecast(Position position) async {
  final String baseUrl =
      "https://9b81-2409-40f0-6-65a5-b975-3ad1-30c5-3441.ngrok-free.app";

  try {
    final response = await http.post(
      Uri.parse("$baseUrl/predicttodayWeather"), // Fixed endpoint
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"latitude": position.latitude, "longitude": position.longitude}),
    );

    print("\n\nStatus code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get Weather Data: ${response.body}");
    }
  } catch (e) {
    print("Error in getting Weather Data: $e");
    throw Exception("Error Weather Data: $e");
  }
}
