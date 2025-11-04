import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/core/constants/image_assets.dart';
import 'package:inawl_app/core/routes/app_routes.dart';
import 'package:inawl_app/widgets/pattern_banner.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  // Pattern names for library display (excludes Unknown)
  static const List<String> patternNames = [
    'BB Queen',
    'Bailabi',
    'Binaludan Diamond',
    'Binaludto',
    'Diamond Magnet',
    'Katompi',
    'Kinayupo',
    'Kinulipis',
    'Lumbayan',
    'Pakiring',
    'Panigabi',
    'Pine Tree',
    'Pinundutan',
    'Pinya',
    'Sahaya',
    'Salimpukaw',
    'Sambit',
    'Siko Karwang',
    'Siku Andun',
    'Sultan',
    'Sunflower',
    'Tipas',
    // Unknown is excluded from library display
  ];

  @override
  Widget build(BuildContext context) {
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
                    'Inaul Library',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    'Browse through our Inaul Library! Tap on an image to learn more about the pattern.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingExtraLarge),

                  // Grid of actual images with labels
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: AppConstants.gridCrossAxisCount,
                        mainAxisSpacing: AppConstants.gridMainAxisSpacing,
                        crossAxisSpacing: AppConstants.gridCrossAxisSpacing,
                        childAspectRatio: 0.75, // Adjust ratio to accommodate label
                      ),
                      itemCount: ImageAssets.libraryDisplayImages.length,
                      itemBuilder: (context, index) {
                        return _buildImageCard(
                          ImageAssets.libraryDisplayImages[index],
                          patternNames[index],
                          context,
                        );
                      },
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

  Widget _buildImageCard(String imagePath, String label, BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.imageBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          AppRoutes.navigateToPattern(context, label, imagePath);
        },
        borderRadius: BorderRadius.circular(AppConstants.imageBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.imageBorderRadius),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
