import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  
  static const String modelPath = 'assets/model/effi_full.tflite';
  static const String labelsPath = 'assets/model/labels.txt';

  /// Load the TFLite model and labels
  static Future<void> loadModel() async {
    try {
      // Load model
      _interpreter = await Interpreter.fromAsset(modelPath);
      print('✓ Model loaded successfully');
      print('  Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('  Output shape: ${_interpreter!.getOutputTensor(0).shape}');
      
      // Load labels
      final labelsData = await rootBundle.loadString(labelsPath);
      _labels = labelsData.split('\n').where((label) => label.trim().isNotEmpty).toList();
      print('✓ Loaded ${_labels!.length} labels');
    } catch (e) {
      print('✗ Error loading model: $e');
      rethrow;
    }
  }

  /// Preprocess image for model input - resize to 384x384
  static List<List<List<List<double>>>> preprocessImage(String imagePath) {
    // Read image file
    final imageFile = File(imagePath);
    final bytes = imageFile.readAsBytesSync();
    
    // Decode image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to 384x384 (model input size)
    const inputSize = 384;
    print('Resizing image to ${inputSize}x${inputSize}');
    
    img.Image resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );

    // Convert to input format [1, height, width, 3]
    var input = List.generate(
      1,
      (i) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0, // Normalize to [0, 1]
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    return input;
  }

  /// Classify an image and return predictions
  static Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    try {
      print('Classifying image: $imagePath');
      
      // Preprocess image
      var input = preprocessImage(imagePath);

      // Prepare output buffer
      var output = List.filled(1, List.filled(_labels!.length, 0.0))
          .map((e) => List<double>.filled(_labels!.length, 0.0))
          .toList();

      // Run inference
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(input, output);
      stopwatch.stop();
      print('Inference time: ${stopwatch.elapsedMilliseconds}ms');

      // Get predictions
      List<double> probabilities = output[0];

      // Find the class with highest probability
      int maxIndex = 0;
      double maxProb = probabilities[0];
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // Get top 3 predictions
      List<MapEntry<int, double>> indexed = [];
      for (int i = 0; i < probabilities.length; i++) {
        indexed.add(MapEntry(i, probabilities[i]));
      }
      indexed.sort((a, b) => b.value.compareTo(a.value));

      List<Map<String, dynamic>> topPredictions = indexed
          .take(3)
          .map((entry) => {
                'class': _labels![entry.key],
                'confidence': entry.value,
                'percentage': (entry.value * 100).toStringAsFixed(2),
              })
          .toList();

      final result = {
        'predictedClass': _labels![maxIndex],
        'confidence': maxProb,
        'percentage': (maxProb * 100).toStringAsFixed(1),
        'topPredictions': topPredictions,
      };
      
      print('✓ Predicted: ${result['predictedClass']} (${result['percentage']}%)');
      
      return result;
    } catch (e) {
      print('✗ Error during classification: $e');
      rethrow;
    }
  }

  /// Get list of class labels
  static List<String> get classNames => _labels ?? [];

  /// Dispose the interpreter
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
