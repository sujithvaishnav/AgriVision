import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../Models/loginModel.dart';
import 'languageselectionpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final LoginModel _loginModel = LoginModel();

  bool _isOtpSent = false;
  String _phoneNumber = '';

  void _sendOtp() async {
    String phone = _phoneController.text.trim();
    if (phone.length != 10) {
      _showMessage("Enter a valid 10-digit phone number");
      return;
    }

    try {
      var response = await _loginModel.sendOtp("+91$phone");
      if (response.containsKey("session_id")) {
        setState(() {
          _isOtpSent = true;
          _phoneNumber = "+91$phone";
        });
        _showMessage("OTP sent successfully!");
      } else {
        _showMessage("Failed to send OTP. Try again.");
      }
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _verifyOtp() async {
    String otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 4) {
      _showMessage("Enter a valid 4-digit OTP");
      return;
    }

    try {
      bool isVerified = await _loginModel.verifyOtp(_phoneNumber, otp);
      if (isVerified) {
        _showMessage("Login successful!");
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LanguageSelectionPage()),
            );
          }
        });
      } else {
        _showMessage("Invalid OTP. Please try again.");
      }
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _resendOtp() async {
    try {
      var response = await _loginModel.resendOtp(_phoneNumber);
      if (response.containsKey("session_id")) {
        _showMessage("OTP resent successfully!");
      } else {
        _showMessage("Failed to resend OTP. Try again.");
      }
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _changeNumber() {
    setState(() {
      _isOtpSent = false;
      _phoneController.clear();
      _otpController.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Logo
              Image.asset('assets/images/logo.jpg',
                  height: 100), // Add your logo

              const SizedBox(height: 20),

              // Phone Number Input
              if (!_isOtpSent) ...[
                const Text(
                  "Login with Phone",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone),
                    prefixText: "+91 ",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Phone Number",
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                // OTP Input
                const Text(
                  "Enter OTP",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Pinput(
                  controller: _otpController,
                  length: 4,
                  pinAnimationType: PinAnimationType.fade,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _resendOtp,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text("Resend OTP"),
                    ),
                    TextButton.icon(
                      onPressed: _changeNumber,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Change Number"),
                    ),
                  ],
                ),
              ],

              // Submit Button
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(_isOtpSent ? Icons.check : Icons.send),
                  label: Text(
                    _isOtpSent ? "Verify OTP" : "Send OTP",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
