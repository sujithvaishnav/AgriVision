import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../Models/mlApiService.dart';
import '../Models/classNameModel.dart';
import '../Models/recommendationModel.dart';
import '../Resources/appLocalizations.dart';
import '../Resources/languageChanger.dart';

class DetailsPage extends StatefulWidget {
  final File image;

  DetailsPage({required this.image});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final ModelService _modelService = ModelService();
  final ClassesList _classesList = ClassesList();

  String? _predictionResult;
  String? resultName;
  String? translatedDescription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      String prediction = await _predictImage();
      resultName = _classesList.getClassName(prediction);
      String translatedName =
          AppLocalizations.of(context)!.translate(resultName!);

      String description = await diseaseDescription(resultName!);
      translatedDescription = await _translateText(description);

      setState(() {
        _predictionResult = translatedName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _predictionResult = "Prediction Failed";
        translatedDescription = "Error: $e";
        _isLoading = false;
      });
    }
  }

  Future<String> _predictImage() async {
    var connectivity = await Connectivity().checkConnectivity();
    bool isOnline = connectivity != ConnectivityResult.none;

    if (isOnline) {
      String? result = await _modelService.predictOnline(widget.image);
      return result.isNotEmpty && result != "Error: Server Unreachable"
          ? result
          : await _modelService.predictOffline(widget.image);
    }
    return await _modelService.predictOffline(widget.image);
  }

  Future<String> _translateText(String text) async {
    LanguageProvider translator =
        Provider.of<LanguageProvider>(context, listen: false);
    final response = await translator.translate(text);
    return response["translated_text"] ?? "Translation failed";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate("Image Details"),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(136, 179, 247, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 20.0),
            child: _isLoading
                ? CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildImageCard(),
                      SizedBox(height: 20),
                      _buildPredictionCard(),
                      SizedBox(height: 20),
                      _buildDescriptionCard(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(widget.image,
              width: 200, height: 200, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _predictionResult ?? "Try Again",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 13, 16),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.translate("Description"),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            translatedDescription ?? "No description available",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
