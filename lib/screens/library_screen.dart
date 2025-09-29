import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/core/constants/image_assets.dart';
import 'package:inawl_app/widgets/back_button.dart' as custom;
import 'package:inawl_app/widgets/pattern_banner.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

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
                  // Back Button
                  const custom.BackButtonWidget(),

                  const SizedBox(height: AppConstants.spacingMedium),
                  Text(
                    'Inaul Library',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                  Text(
                    'Browse through our growing Inaul Library!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingExtraLarge),

                  // Grid of actual images
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: AppConstants.gridCrossAxisCount,
                        mainAxisSpacing: AppConstants.gridMainAxisSpacing,
                        crossAxisSpacing: AppConstants.gridCrossAxisSpacing,
                      ),
                      itemCount: ImageAssets.libraryImages.length,
                      itemBuilder: (context, index) {
                        return _buildImageCard(ImageAssets.libraryImages[index]);
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

  Widget _buildImageCard(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.imageBorderRadius),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
      ),
    );
  }
}
