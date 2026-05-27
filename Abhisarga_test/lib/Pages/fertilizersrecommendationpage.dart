import 'dart:convert';

import 'package:abhisarga_test/Resources/languageChanger.dart';
import 'package:provider/provider.dart';
import '../Models/recommendationModel.dart';
import 'package:flutter/material.dart';

import '../Resources/appLocalizations.dart';

class FertilizerRecommendationPage extends StatefulWidget {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double ph;
  final bool ismanual;

  const FertilizerRecommendationPage({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.ismanual,
  });

  @override
  _FertilizerRecommendationPageState createState() =>
      _FertilizerRecommendationPageState();
}

class _FertilizerRecommendationPageState
    extends State<FertilizerRecommendationPage> {
  String selectedCrop = "";
  String fertilizerDescription = "";
  String translatedText = "";
  bool isLoading = false;

  final List<Map<String, String>> crops = [
    {"name": "Wheat", "image": "assets/images/wheat.jpg"},
    {"name": "Rice", "image": "assets/images/rice.jpg"},
    {"name": "Maize", "image": "assets/images/maize.jpg"},
    {"name": "Sugarcane", "image": "assets/images/sugarcane.jpg"},
    {"name": "Tomato", "image": "assets/images/tomato.jpg"},
    {"name": "Cotton", "image": "assets/images/cotton.jpg"},
    {"name": "Soybean", "image": "assets/images/soyabean.jpg"},
    {"name": "Potato", "image": "assets/images/potato.jpg"},
    {"name": "Barley", "image": "assets/images/barley.jpg"},
    {"name": "Mustard", "image": "assets/images/mustard.jpg"},
  ];

  void getFertilizerDescription(String crop) async {
    setState(() {
      selectedCrop = crop;
      isLoading = true;
      fertilizerDescription = "";
      translatedText = "";
    });

    try {
      var result = await fertilizerRecommendation(
        widget.nitrogen,
        widget.phosphorus,
        widget.potassium,
        widget.ph,
        crop,
        widget.ismanual,
      );

      setState(() {
        fertilizerDescription = result.toString();
      });
      await translateFertilizerDescription(result.toString());
    } catch (e) {
      setState(() {
        fertilizerDescription = "Error fetching recommendation.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> translateFertilizerDescription(String text) async {
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

  @override
  Widget build(BuildContext context) {
    Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate("Fertilizer Recommendation"),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(136, 179, 247, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.translate("Select a crop"),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              flex: 2, // Increases space for crop selection
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
                ),
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedCrop == crops[index]["name"];
                  return GestureDetector(
                    onTap: () =>
                        getFertilizerDescription(crops[index]["name"]!),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.greenAccent
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Image.asset(
                            crops[index]["image"]!,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image_not_supported,
                                  size: 40, color: Colors.grey);
                            },
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate(crops[index]["name"]!),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
                height: 10), // Reduced gap between crop list and description
            Expanded(
              flex: 2, // Increases height of description card
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .translate("Fertilizer Recommendation"),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: isLoading
                                ? Center(child: CircularProgressIndicator())
                                : SingleChildScrollView(
                                    child: Text(
                                      translatedText.isNotEmpty
                                          ? translatedText
                                          : fertilizerDescription,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
