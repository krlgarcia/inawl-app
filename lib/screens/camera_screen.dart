import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/core/constants/image_assets.dart';
import 'package:inawl_app/core/routes/app_routes.dart';
import 'package:inawl_app/services/model_service.dart';
import 'package:inawl_app/screens/image_crop_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      await _controller!.setFlashMode(
        _isTorchOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      debugPrint('Error toggling torch: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Torch not available on this device'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture the full image
      final XFile image = await _controller!.takePicture();
      debugPrint('Picture taken: ${image.path}');

      // Crop and resize the image to 384x384 from the frame area
      final croppedImagePath = await _cropImageToFrame(image.path);
      
      // Run ML inference
      final result = await ModelService.classifyImage(croppedImagePath);
      final predictedClass = result['predictedClass'] as String;
      final confidence = result['percentage'] as String;
      
      // Find the matching library image
      final patternIndex = ModelService.classNames.indexOf(predictedClass);
      final imagePath = patternIndex >= 0 && patternIndex < ImageAssets.libraryImages.length
          ? ImageAssets.libraryImages[patternIndex]
          : ImageAssets.libraryImages[0];
      
      if (mounted) {
        // Navigate to pattern screen with captured image and confidence
        AppRoutes.navigateToPattern(
          context,
          predictedClass,
          imagePath,
          capturedImagePath: croppedImagePath,
          confidence: confidence,
        );
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Crop image to the frame area and resize to 384x384
  Future<String> _cropImageToFrame(String imagePath) async {
    // Load the captured image
    final bytes = await File(imagePath).readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);
    
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    // Get the screen size to calculate frame position
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate frame dimensions (matching CameraOverlayPainter)
    final frameSize = screenWidth * 0.8;
    final frameLeft = (screenWidth - frameSize) / 2;
    final frameTop = (screenHeight - frameSize) / 2;
    
    // Calculate the crop area in the original image coordinates
    final imageWidth = originalImage.width;
    final imageHeight = originalImage.height;
    
    // Scale factors
    final scaleX = imageWidth / screenWidth;
    final scaleY = imageHeight / screenHeight;
    
    // Crop coordinates in original image
    final cropLeft = (frameLeft * scaleX).toInt();
    final cropTop = (frameTop * scaleY).toInt();
    final cropSize = (frameSize * scaleX).toInt();
    
    // Crop the image to the frame area
    img.Image croppedImage = img.copyCrop(
      originalImage,
      x: cropLeft,
      y: cropTop,
      width: cropSize,
      height: cropSize,
    );
    
    // Resize to 384x384
    img.Image resizedImage = img.copyResize(
      croppedImage,
      width: 384,
      height: 384,
    );
    
    // Save the cropped and resized image
    final directory = await getTemporaryDirectory();
    final croppedPath = '${directory.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(img.encodeJpg(resizedImage));
    
    debugPrint('Cropped image saved to: $croppedPath');
    return croppedPath;
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint('Image selected from gallery: ${image.path}');
        
        if (mounted) {
          // Navigate to crop screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImageCropScreen(imagePath: image.path),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing gallery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitialized
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Camera preview - full screen behind everything
                  OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),

                  // Overlay with frame guide
                  CustomPaint(
                    painter: CameraOverlayPainter(),
                  ),

                  // Instructions at the top
                  Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Position the Inaul fabric',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              shadows: [
                                const Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'within the frame',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              shadows: [
                                const Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom controls (positioned at bottom)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: AppConstants.defaultPadding,
                      ),
                      child: Column(
                        children: [
                          // Capture button (centered)
                          GestureDetector(
                            onTap: _isInitialized && !_isProcessing ? _takePicture : null,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: _isProcessing
                                  ? const Padding(
                                      padding: EdgeInsets.all(15),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Center(
                                      child: Container(
                                        width: 54,
                                        height: 54,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Torch button (lower right corner)
                  Positioned(
                    bottom: 40,
                    right: 30,
                    child: GestureDetector(
                      onTap: _toggleTorch,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.6),
                          border: Border.all(
                            color: _isTorchOn 
                                ? Colors.yellow 
                                : Colors.white.withOpacity(0.7),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: _isTorchOn ? Colors.yellow : Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                  // Gallery button (lower left corner)
                  Positioned(
                    bottom: 40,
                    left: 30,
                    child: GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.6),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.7),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// Custom painter for the camera overlay frame
class CameraOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Calculate the frame dimensions (centered square - 1:1 aspect ratio)
    final frameSize = size.width * 0.8; // Square frame
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;

    // Draw corner brackets
    final cornerLength = 40.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      paint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + frameSize - cornerLength, top),
      Offset(left + frameSize, top),
      paint,
    );
    canvas.drawLine(
      Offset(left + frameSize, top),
      Offset(left + frameSize, top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + frameSize - cornerLength),
      Offset(left, top + frameSize),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + frameSize),
      Offset(left + cornerLength, top + frameSize),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + frameSize - cornerLength, top + frameSize),
      Offset(left + frameSize, top + frameSize),
      paint,
    );
    canvas.drawLine(
      Offset(left + frameSize, top + frameSize - cornerLength),
      Offset(left + frameSize, top + frameSize),
      paint,
    );

    // Draw semi-transparent overlay outside the frame
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Top overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, top),
      overlayPaint,
    );

    // Bottom overlay
    canvas.drawRect(
      Rect.fromLTWH(0, top + frameSize, size.width, size.height - (top + frameSize)),
      overlayPaint,
    );

    // Left overlay
    canvas.drawRect(
      Rect.fromLTWH(0, top, left, frameSize),
      overlayPaint,
    );

    // Right overlay
    canvas.drawRect(
      Rect.fromLTWH(left + frameSize, top, size.width - (left + frameSize), frameSize),
      overlayPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
