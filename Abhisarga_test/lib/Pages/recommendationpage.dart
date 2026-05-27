import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/recommendationModel.dart';
import '../Resources/appLocalizations.dart';
import '../Resources/languageChanger.dart';
import 'fertilizersrecommendationpage.dart';

class RecommendationPage extends StatefulWidget {
  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  bool isManualInput = false;
  String translatedText = "";
  final TextEditingController nController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController kController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  String recommendedCrop = "";
  bool isLoading = false;

  double parseInput(String input) {
    try {
      return double.parse(input);
    } catch (e) {
      return 0.0;
    }
  }

  void getCropRecommendation() async {
    try {
      setState(() => isLoading = true);
      var result = await cropRecommendation(
        parseInput(nController.text),
        parseInput(pController.text),
        parseInput(kController.text),
        parseInput(phController.text),
        isManualInput,
      );
      setState(() {
        recommendedCrop = result.toString();
      });

      await translateCropName(result.toString());
    } catch (e) {
      setState(() {
        translatedText = "Error fetching recommendation";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void navigateToFertilizerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FertilizerRecommendationPage(
          nitrogen: parseInput(nController.text),
          phosphorus: parseInput(pController.text),
          potassium: parseInput(kController.text),
          ph: parseInput(phController.text),
          ismanual: isManualInput,
        ),
      ),
    );
  }

  Future<void> translateCropName(String text) async {
    try {
      LanguageProvider translator =
          Provider.of<LanguageProvider>(context, listen: false);

      // Directly receive the JSON response as a Map
      Map<String, dynamic> response = await translator.translate(text);
      print("Translation API Response: $response");

      if (!response.containsKey('translated_text')) {
        throw Exception("Invalid translation response format");
      }

      String translatedTextValue = response['translated_text'];

      setState(() {
        translatedText = translatedTextValue;
      });
    } catch (e) {
      print("Error in translation: $e");
      setState(() {
        translatedText = "Translation failed";
      });
    }
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Opacity(
              opacity: isManualInput ? 1.0 : 0.8,
              child: TextField(
                controller: controller,
                enabled: isManualInput,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(
                  color: isManualInput ? Colors.black : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    Color color = Colors.blue,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!
              .translate("Crop & Ferilizer Recommendation"),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isManualInput,
                  onChanged: (value) {
                    setState(() {
                      isManualInput = value!;
                    });
                  },
                ),
                Text(AppLocalizations.of(context)!
                    .translate("Provide Soil Data Manually")),
              ],
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildInputCard(
                    label:
                        AppLocalizations.of(context)!.translate("Nitrogen (N)"),
                    controller: nController,
                    hint: "kg/ha"),
                _buildInputCard(
                    label: AppLocalizations.of(context)!
                        .translate("Phosphorous (P)"),
                    controller: pController,
                    hint: "kg/ha"),
                _buildInputCard(
                    label: AppLocalizations.of(context)!
                        .translate("Potassium (K)"),
                    controller: kController,
                    hint: "kg/ha"),
                _buildInputCard(
                    label: AppLocalizations.of(context)!.translate("pH Level"),
                    controller: phController,
                    hint: "0-14"),
              ],
            ),
            SizedBox(height: 20),
            _buildStyledButton(
              text: AppLocalizations.of(context)!.translate("Recommend Crop"),
              onPressed: getCropRecommendation,
              isLoading: isLoading,
              color: Colors.green,
            ),
            if (recommendedCrop.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  translatedText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(height: 10),
            _buildStyledButton(
              text: AppLocalizations.of(context)!
                  .translate("View Fertilizer Recommendations"),
              onPressed: navigateToFertilizerPage,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
