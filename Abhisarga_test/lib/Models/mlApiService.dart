import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class ModelService {
  final String serverUrl =
      "https://9b81-2409-40f0-6-65a5-b975-3ad1-30c5-3441.ngrok-free.app/predict"; // Replace with your API

  tfl.Interpreter? _interpreter;
  bool _isModelLoaded = false;

  /// Load TensorFlow Lite model from assets
  Future<void> loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(
          'assets/models/prediction_model.tflite');
      _isModelLoaded = true;
      print("TFLite model loaded successfully.");
    } catch (e) {
      print("Error loading TFLite model: $e");
      _isModelLoaded = false;
    }
  }

  /// Perform TFLite inference offline
  Future<String> predictOffline(File imageFile) async {
    if (!_isModelLoaded) {
      await loadModel();
      if (!_isModelLoaded || _interpreter == null) {
        return "Error: Model failed to load.";
      }
    }

    // Decode and preprocess image
    final imageBytes = imageFile.readAsBytesSync();
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      return "Error: Failed to decode image.";
    }

    img.Image image = img.copyResize(decodedImage,
        width: 224, height: 224, interpolation: img.Interpolation.linear);
    Float32List input = imageToByteList(image, 224);

    // Prepare input tensor
    var inputTensor = input.reshape([1, 224, 224, 3]);

    // Prepare output tensor (adjust based on model output shape)
    var outputTensor = List.filled(1 * 55, 0.0).reshape([1, 55]);

    try {
      // Run inference
      _interpreter!.run(inputTensor, outputTensor);

      // Process output
      final List<double> prediction = List<double>.from(outputTensor[0]);
      final predictedClass =
          prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));

      print("Predicted Class: $predictedClass (Scores: $prediction)");
      return "$predictedClass";
    } catch (e) {
      print("\n\nError during inference: $e\n\n");
      return "Error during inference: $e";
    }
  }

  /// Perform inference via a server API
  Future<String> predictOnline(File imageFile) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(serverUrl));
      request.files
          .add(await http.MultipartFile.fromPath("image", imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseBody);
        return jsonResponse["predicted_class"].toString();
      } else if (response.statusCode == 404) {
        print("❌ Server Not Found (404)");
        return "Error: Server Not Found (404)";
      } else {
        print(
            "❌ Server Error: ${response.statusCode} - ${response.reasonPhrase}");
        return "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      if (e is SocketException) {
        print("❌ Connection Error: Unable to reach the server.");
        return "Error: Server Unreachable";
      } else if (e is TimeoutException) {
        print("❌ Timeout Error: Server took too long to respond.");
        return "Error: Server Timeout";
      } else {
        print("❌ Unknown Error: $e");
        return "Error: $e";
      }
    }
  }

  /// Convert image to TFLite-friendly input
  Float32List imageToByteList(img.Image image, int inputSize) {
    var convertedBytes = Float32List(inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r / 255.0; // Extract Red
        final g = pixel.g / 255.0; // Extract Green
        final b = pixel.b / 255.0; // Extract Blue

        buffer[pixelIndex++] = r;
        buffer[pixelIndex++] = g;
        buffer[pixelIndex++] = b;
      }
    }
    return buffer;
  }
}
