import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:inawl_app/core/constants/image_assets.dart';
import 'package:inawl_app/core/routes/app_routes.dart';
import 'package:inawl_app/services/model_service.dart';

class ImageCropScreen extends StatefulWidget {
  final String imagePath;

  const ImageCropScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  ui.Image? _image;
  bool _isLoading = true;
  bool _isProcessing = false;
  Offset _frameOffset = Offset.zero;
  double _frameSize = 0;
  Size _imageDisplaySize = Size.zero;
  Offset _imageOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final file = File(widget.imagePath);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    
    setState(() {
      _image = frame.image;
      _isLoading = false;
    });

    // Calculate initial frame position after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateInitialFrame();
    });
  }

  void _calculateInitialFrame() {
    if (_image == null) return;

    final screenSize = MediaQuery.of(context).size;
    final imageAspectRatio = _image!.width / _image!.height;
    final screenAspectRatio = screenSize.width / screenSize.height;

    // Calculate how the image fits on screen
    if (imageAspectRatio > screenAspectRatio) {
      // Image is wider - fit to width
      _imageDisplaySize = Size(
        screenSize.width,
        screenSize.width / imageAspectRatio,
      );
    } else {
      // Image is taller - fit to height
      _imageDisplaySize = Size(
        screenSize.height * imageAspectRatio,
        screenSize.height,
      );
    }

    _imageOffset = Offset(
      (screenSize.width - _imageDisplaySize.width) / 2,
      (screenSize.height - _imageDisplaySize.height) / 2,
    );

    // Set initial frame size to 80% of the smaller dimension
    final maxFrameSize = _imageDisplaySize.width < _imageDisplaySize.height
        ? _imageDisplaySize.width * 0.8
        : _imageDisplaySize.height * 0.8;
    
    _frameSize = maxFrameSize;
    
    // Center the frame on the image
    _frameOffset = Offset(
      (screenSize.width - _frameSize) / 2,
      (screenSize.height - _frameSize) / 2,
    );

    setState(() {});
  }

  Future<void> _cropAndProcess() async {
    if (_image == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Load the original image using the image package
      final bytes = await File(widget.imagePath).readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate the crop area in the original image coordinates
      final scaleX = originalImage.width / _imageDisplaySize.width;
      final scaleY = originalImage.height / _imageDisplaySize.height;
      
      final cropLeft = ((_frameOffset.dx - _imageOffset.dx) * scaleX).toInt().clamp(0, originalImage.width);
      final cropTop = ((_frameOffset.dy - _imageOffset.dy) * scaleY).toInt().clamp(0, originalImage.height);
      final cropSize = (_frameSize * scaleX).toInt().clamp(1, originalImage.width - cropLeft);
      
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
      
      // Run ML inference
      final result = await ModelService.classifyImage(croppedPath);
      final predictedClass = result['predictedClass'] as String;
      final confidence = result['percentage'] as String;
      
      // Find the matching library image
      final patternIndex = ModelService.classNames.indexOf(predictedClass);
      final imagePath = patternIndex >= 0 && patternIndex < ImageAssets.libraryImages.length
          ? ImageAssets.libraryImages[patternIndex]
          : ImageAssets.libraryImages[0];
      
      if (mounted) {
        // Navigate to pattern screen with captured image and confidence
        Navigator.of(context).pop(); // Close crop screen
        AppRoutes.navigateToPattern(
          context,
          predictedClass,
          imagePath,
          capturedImagePath: croppedPath,
          confidence: confidence,
        );
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Stack(
                children: [
                  // Display the image
                  if (_image != null)
                    Positioned(
                      left: _imageOffset.dx,
                      top: _imageOffset.dy,
                      child: SizedBox(
                        width: _imageDisplaySize.width,
                        height: _imageDisplaySize.height,
                        child: RawImage(
                          image: _image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                  // Overlay with adjustable frame
                  CustomPaint(
                    size: Size.infinite,
                    painter: CropOverlayPainter(
                      frameOffset: _frameOffset,
                      frameSize: _frameSize,
                    ),
                  ),

                  // Draggable frame
                  Positioned(
                    left: _frameOffset.dx,
                    top: _frameOffset.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          final newX = _frameOffset.dx + details.delta.dx;
                          final newY = _frameOffset.dy + details.delta.dy;
                          
                          // Constrain within image bounds
                          final maxX = _imageOffset.dx + _imageDisplaySize.width - _frameSize;
                          final maxY = _imageOffset.dy + _imageDisplaySize.height - _frameSize;
                          
                          _frameOffset = Offset(
                            newX.clamp(_imageOffset.dx, maxX),
                            newY.clamp(_imageOffset.dy, maxY),
                          );
                        });
                      },
                      child: Container(
                        width: _frameSize,
                        height: _frameSize,
                        color: Colors.transparent,
                      ),
                    ),
                  ),

                  // Instructions at the top
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          Text(
                            'Adjust the frame',
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
                            'Drag to reposition',
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

                  // Bottom controls
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
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Cancel button
                          ElevatedButton(
                            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),

                          // Crop and identify button
                          ElevatedButton(
                            onPressed: _isProcessing ? null : _cropAndProcess,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Identify',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }
}

// Custom painter for the crop overlay
class CropOverlayPainter extends CustomPainter {
  final Offset frameOffset;
  final double frameSize;

  CropOverlayPainter({
    required this.frameOffset,
    required this.frameSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final left = frameOffset.dx;
    final top = frameOffset.dy;
    final cornerLength = 40.0;

    // Draw corner brackets
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
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return oldDelegate.frameOffset != frameOffset ||
        oldDelegate.frameSize != frameSize;
  }
}
