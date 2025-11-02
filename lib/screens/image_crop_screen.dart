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
  double _minFrameSize = 100.0;
  double _maxFrameSize = 0;

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

    // Set min and max frame size
    _minFrameSize = 100.0;
    _maxFrameSize = _imageDisplaySize.width < _imageDisplaySize.height
        ? _imageDisplaySize.width
        : _imageDisplaySize.height;

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

  void _handleCornerResize(DragUpdateDetails details, String corner) {
    setState(() {
      double delta = 0;
      
      // Calculate delta based on which corner is being dragged
      switch (corner) {
        case 'topLeft':
          delta = -(details.delta.dx + details.delta.dy) / 2;
          break;
        case 'topRight':
          delta = (details.delta.dx - details.delta.dy) / 2;
          break;
        case 'bottomLeft':
          delta = (-details.delta.dx + details.delta.dy) / 2;
          break;
        case 'bottomRight':
          delta = (details.delta.dx + details.delta.dy) / 2;
          break;
      }
      
      final oldSize = _frameSize;
      final newSize = (oldSize + delta).clamp(_minFrameSize, _maxFrameSize);
      final sizeDiff = newSize - oldSize;
      
      // Adjust offset based on corner being dragged
      var newOffset = _frameOffset;
      
      if (corner.contains('top')) {
        newOffset = Offset(newOffset.dx, newOffset.dy - sizeDiff / 2);
      } else {
        newOffset = Offset(newOffset.dx, newOffset.dy + sizeDiff / 2);
      }
      
      if (corner.contains('Left')) {
        newOffset = Offset(newOffset.dx - sizeDiff / 2, newOffset.dy);
      } else {
        newOffset = Offset(newOffset.dx + sizeDiff / 2, newOffset.dy);
      }
      
      _frameSize = newSize;
      
      // Constrain within image bounds
      final maxX = _imageOffset.dx + _imageDisplaySize.width - _frameSize;
      final maxY = _imageOffset.dy + _imageDisplaySize.height - _frameSize;
      
      _frameOffset = Offset(
        newOffset.dx.clamp(_imageOffset.dx, maxX),
        newOffset.dy.clamp(_imageOffset.dy, maxY),
      );
    });
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

                  // Draggable frame with pinch-to-zoom
                  Positioned(
                    left: _frameOffset.dx,
                    top: _frameOffset.dy,
                    child: GestureDetector(
                      onScaleStart: (details) {
                        // Initialize scale gesture
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          if (details.scale != 1.0) {
                            // Handle resize (pinch)
                            final oldSize = _frameSize;
                            final newSize = (oldSize * details.scale).clamp(_minFrameSize, _maxFrameSize);
                            
                            // Calculate new offset to keep the frame centered at focal point
                            final frameCenter = Offset(
                              _frameOffset.dx + oldSize / 2,
                              _frameOffset.dy + oldSize / 2,
                            );
                            
                            _frameSize = newSize;
                            
                            // Adjust position to keep centered
                            var newOffset = Offset(
                              frameCenter.dx - newSize / 2,
                              frameCenter.dy - newSize / 2,
                            );
                            
                            // Constrain within image bounds
                            final maxX = _imageOffset.dx + _imageDisplaySize.width - _frameSize;
                            final maxY = _imageOffset.dy + _imageDisplaySize.height - _frameSize;
                            
                            _frameOffset = Offset(
                              newOffset.dx.clamp(_imageOffset.dx, maxX),
                              newOffset.dy.clamp(_imageOffset.dy, maxY),
                            );
                          } else {
                            // Handle drag (single finger)
                            final newX = _frameOffset.dx + details.focalPointDelta.dx;
                            final newY = _frameOffset.dy + details.focalPointDelta.dy;
                            
                            // Constrain within image bounds
                            final maxX = _imageOffset.dx + _imageDisplaySize.width - _frameSize;
                            final maxY = _imageOffset.dy + _imageDisplaySize.height - _frameSize;
                            
                            _frameOffset = Offset(
                              newX.clamp(_imageOffset.dx, maxX),
                              newY.clamp(_imageOffset.dy, maxY),
                            );
                          }
                        });
                      },
                      child: Container(
                        width: _frameSize,
                        height: _frameSize,
                        color: Colors.transparent,
                      ),
                    ),
                  ),

                  // Corner resize handles
                  _buildResizeHandle('topLeft'),
                  _buildResizeHandle('topRight'),
                  _buildResizeHandle('bottomLeft'),
                  _buildResizeHandle('bottomRight'),

                  // Instructions at the top
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Adjust Crop Area',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.pan_tool, color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Drag to move',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.zoom_out_map, color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Pinch/corners to resize',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
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
                          ElevatedButton.icon(
                            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 20),
                            label: const Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                          ),

                          // Crop and identify button
                          ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _cropAndProcess,
                            icon: _isProcessing 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_circle, size: 20),
                            label: Text(
                              _isProcessing ? 'Processing...' : 'Identify Pattern',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
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

  Widget _buildResizeHandle(String corner) {
    double left = 0, top = 0;
    
    switch (corner) {
      case 'topLeft':
        left = _frameOffset.dx - 20;
        top = _frameOffset.dy - 20;
        break;
      case 'topRight':
        left = _frameOffset.dx + _frameSize - 20;
        top = _frameOffset.dy - 20;
        break;
      case 'bottomLeft':
        left = _frameOffset.dx - 20;
        top = _frameOffset.dy + _frameSize - 20;
        break;
      case 'bottomRight':
        left = _frameOffset.dx + _frameSize - 20;
        top = _frameOffset.dy + _frameSize - 20;
        break;
    }
    
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (details) => _handleCornerResize(details, corner),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD17A45), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: const Color(0xFFD17A45).withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.open_in_full,
            size: 18,
            color: Color(0xFFD17A45),
          ),
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
    final left = frameOffset.dx;
    final top = frameOffset.dy;
    final cornerLength = 50.0;

    // Draw semi-transparent overlay outside the frame
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
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

    // Draw rule of thirds grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical lines
    final third = frameSize / 3;
    canvas.drawLine(
      Offset(left + third, top),
      Offset(left + third, top + frameSize),
      gridPaint,
    );
    canvas.drawLine(
      Offset(left + third * 2, top),
      Offset(left + third * 2, top + frameSize),
      gridPaint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(left, top + third),
      Offset(left + frameSize, top + third),
      gridPaint,
    );
    canvas.drawLine(
      Offset(left, top + third * 2),
      Offset(left + frameSize, top + third * 2),
      gridPaint,
    );

    // Draw corner brackets with glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFFD17A45).withOpacity(0.5)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final mainPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highlightPaint = Paint()
      ..color = const Color(0xFFD17A45)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawCornerBrackets(canvas, left, top, cornerLength, glowPaint);
    _drawCornerBrackets(canvas, left, top, cornerLength, mainPaint);
    _drawCornerBrackets(canvas, left, top, cornerLength, highlightPaint);
  }

  void _drawCornerBrackets(Canvas canvas, double left, double top, double cornerLength, Paint paint) {
    // Top-left corner
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), paint);

    // Top-right corner
    canvas.drawLine(Offset(left + frameSize - cornerLength, top), Offset(left + frameSize, top), paint);
    canvas.drawLine(Offset(left + frameSize, top), Offset(left + frameSize, top + cornerLength), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(left, top + frameSize - cornerLength), Offset(left, top + frameSize), paint);
    canvas.drawLine(Offset(left, top + frameSize), Offset(left + cornerLength, top + frameSize), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(left + frameSize - cornerLength, top + frameSize), Offset(left + frameSize, top + frameSize), paint);
    canvas.drawLine(Offset(left + frameSize, top + frameSize - cornerLength), Offset(left + frameSize, top + frameSize), paint);
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return oldDelegate.frameOffset != frameOffset ||
        oldDelegate.frameSize != frameSize;
  }
}
