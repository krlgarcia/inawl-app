import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/widgets/pattern_banner.dart';

class UnknownPatternScreen extends StatelessWidget {
  final String? capturedImagePath;
  final String? confidence;

  const UnknownPatternScreen({
    super.key,
    this.capturedImagePath,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top patterned banner
          const PatternBanner(isTop: true),

          // Content - make entire content scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spacingMedium),
                  
                  // Warning card (with header inside)
                  _buildUnknownWarning(context),
                  
                  const SizedBox(height: AppConstants.spacingExtraLarge),

                  // Show captured image if available
                  if (capturedImagePath != null) ...[
                    Text(
                      'Your Photo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.imageBorderRadius),
                      child: Image.file(
                        File(capturedImagePath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingExtraLarge),
                  ],

                  // Help content section
                  Text(
                    'What Can You Do?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    _getHelpText(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                ],
              ),
            ),
          ),

          // Bottom patterned banner
          const PatternBanner(isTop: false),
        ],
      ),
    );
  }

  Widget _buildUnknownWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade100.withOpacity(0.3),
            Colors.orange.shade50.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade700, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pattern Not Recognized',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'The app could not identify this as a known Inaul pattern. This may happen if:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(context, 'The image doesn\'t show a clear Inaul pattern'),
          _buildBulletPoint(context, 'Lighting or focus is poor'),
          _buildBulletPoint(context, 'The pattern is a variation not in our database'),
          _buildBulletPoint(context, 'Only part of the pattern is visible'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Try again with better lighting and ensure the entire pattern is visible in the frame.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHelpText() {
    return 'We were unable to identify this image as a known Inaul pattern. The image quality, lighting, angle, or content may not be suitable for accurate pattern recognition.\n\n'
        'Tips for better results:\n'
        '• Ensure good, even lighting when capturing the image\n'
        '• Keep the camera steady and in focus\n'
        '• Capture the entire pattern within the frame\n'
        '• Avoid shadows, glare, or reflections\n'
        '• Make sure the fabric is flat and unwrinkled\n\n'
        'If you believe this is an Inaul pattern, please try capturing the image again following these guidelines. '
        'You can also browse our library to see if you can identify the pattern manually.';
  }
}
