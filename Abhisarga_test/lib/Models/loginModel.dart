import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginModel {
  final String baseUrl =
      "https://9b81-2409-40f0-6-65a5-b975-3ad1-30c5-3441.ngrok-free.app"; // Flask Local Server

  /// Sends OTP to the given phone number
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      print("\n\nStatus code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse.containsKey("session_id")) {
          return {"session_id": decodedResponse["session_id"]};
        } else {
          throw Exception("Response does not contain session_id.");
        }
      } else {
        throw Exception("Failed to send OTP: ${response.body}");
      }
    } catch (e) {
      print("Error sending OTP: $e");
      throw Exception("Error sending OTP: $e");
    }
  }

  /// Verifies the OTP entered by the user
  Future<bool> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "otp": otp}),
      );

      print("\n\nStatus code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Invalid OTP: ${response.body}");
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      throw Exception("Error verifying OTP: $e");
    }
  }

  /// Resends OTP by calling sendOtp function again
  Future<Map<String, dynamic>> resendOtp(String phone) async {
    return await sendOtp(phone);
  }

  /// Changes the phone number (Clears session if required)
  Future<Map<String, dynamic>> changeNumber(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/change-number"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      print("\n\nStatus code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to change number: ${response.body}");
      }
    } catch (e) {
      print("Error changing number: $e");
      throw Exception("Error changing number: $e");
    }
  }
}
