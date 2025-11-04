import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/widgets/pattern_banner.dart';

class PatternScreen extends StatelessWidget {
  final String patternName;
  final String imagePath;
  final String? capturedImagePath;
  final String? confidence;

  const PatternScreen({
    super.key,
    required this.patternName,
    required this.imagePath,
    this.capturedImagePath,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    // Parse confidence value for color coding
    final confidenceValue = confidence != null ? double.tryParse(confidence!) : null;
    
    return Scaffold(
      body: Column(
        children: [
          // Top patterned banner
          const PatternBanner(isTop: true),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    patternName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  
                  // Show confidence if available
                  if (confidence != null && confidenceValue != null) ...[
                    const SizedBox(height: AppConstants.spacingMedium),
                    _buildConfidenceDisplay(context, confidenceValue),
                  ],
                  
                  const SizedBox(height: AppConstants.spacingExtraLarge),

                  // Show both images side by side if captured image exists
                  if (capturedImagePath != null) ...[
                    Row(
                      children: [
                        // Captured image
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Pattern library image
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Library Pattern',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppConstants.imageBorderRadius),
                                child: Image.asset(
                                  imagePath,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Pattern image only (when browsing library)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.imageBorderRadius),
                      child: Image.asset(
                        imagePath,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: AppConstants.spacingExtraLarge),

                  // Scrollable text content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About $patternName',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Text(
                            _getPatternDescription(patternName),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildConfidenceDisplay(BuildContext context, double confidenceValue) {
    final confidenceLevel = _getConfidenceLevel(confidenceValue);
    final color = _getConfidenceColor(confidenceValue);
    final icon = _getConfidenceIcon(confidenceValue);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular confidence indicator
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(color: color, width: 3),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${confidenceValue.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Confidence details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      confidenceLevel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getConfidenceMessage(confidenceValue),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: confidenceValue / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getConfidenceLevel(double confidence) {
    if (confidence >= 90) return 'Very High Confidence';
    if (confidence >= 80) return 'High Confidence';
    if (confidence >= 70) return 'Moderate Confidence';
    if (confidence >= 60) return 'Low Confidence';
    return 'Uncertain Result';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 90) return Colors.green.shade700;      // Very High: Dark Green
    if (confidence >= 80) return Colors.lightGreen.shade700; // High: Light Green
    if (confidence >= 70) return Colors.amber.shade700;      // Moderate: Amber
    if (confidence >= 60) return Colors.orange.shade700;     // Low: Orange
    return Colors.red.shade700;                              // Uncertain: Red
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 90) return Icons.check_circle;         // Very High
    if (confidence >= 80) return Icons.check_circle_outline; // High
    if (confidence >= 70) return Icons.info;                 // Moderate
    if (confidence >= 60) return Icons.info_outline;         // Low
    return Icons.warning;                                    // Uncertain
  }

  String _getConfidenceMessage(double confidence) {
    if (confidence >= 90) return 'Strong pattern match!';
    if (confidence >= 80) return 'Pattern detected';
    if (confidence >= 70) return 'Pattern likely detected';
    if (confidence >= 60) return 'Possible match detected';
    return 'Pattern not clearly detected';
  }

  String _getPatternDescription(String patternName) {
    // Pattern-specific lorem ipsum descriptions
    final descriptions = {
      'BB Queen': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
      
      'Bailabi': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
      
      'Binaludan Diamond': 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
      
      'Binaludto': 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.',
      
      'Diamond Magnet': 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.',
      
      'Katompi': 'Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus.',
      
      'Kinayupo': 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga.',
      
      'Kinulipis': 'Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae.',
      
      'Lumbayan': 'Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.',
      
      'Pakiring': 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.',
      
      'Panigabi': 'Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus.',
      
      'Pine Tree': 'Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus.',
      
      'Pinundutan': 'Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint.',
      
      'Pinya': 'Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur.',
      
      'Sahaya': 'Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet.',
      
      'Salimpukaw': 'Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur. At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti.',
      
      'Sambit': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore.',
      
      'Siko Karwang': 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit.',
      
      'Siku Andun': 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.',
      
      'Sultan': 'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur.',
      
      'Sunflower': 'Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae.',
      
      'Tipas': 'Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est.',
    };

    return descriptions[patternName] ?? 'Pattern description not available.';
  }
}
