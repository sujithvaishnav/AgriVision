import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Resources/languageChanger.dart';

class LanguageSelectionPage extends StatefulWidget {
  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    final countryCode = prefs.getString('country_code') ?? 'US';
    setState(() {
      _selectedLocale = Locale(languageCode, countryCode);
    });
  }

  Future<void> _saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
  }

  void _onNextPressed() async {
    if (_selectedLocale == null) {
      _showMessage("Please select a language");
      return;
    }

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.changeLanguage(_selectedLocale!);

    await _saveLanguage(_selectedLocale!);

    if (mounted) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // App Logo
                Image.asset('assets/images/logo.jpg',
                    height: 100), // Replace with your logo path

                const SizedBox(height: 20),

                // Title
                const Text(
                  "Select Your Language",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // Language List
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: LanguageProvider.supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final lang = LanguageProvider.supportedLanguages[index];
                      final Locale locale = lang['locale'] as Locale;
                      bool isSelected = _selectedLocale == locale;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLocale = locale;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Color.fromRGBO(136, 179, 247, 1)
                                  : Colors.grey,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected
                                ? Color.fromRGBO(136, 179, 247, 0.10)
                                : Colors.white,
                          ),
                          child: Text(
                            lang['name'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              color: isSelected
                                  ? Color.fromRGBO(136, 179, 247, 1)
                                  : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(136, 179, 247, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
