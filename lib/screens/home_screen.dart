import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/core/routes/app_routes.dart';
import 'package:inawl_app/widgets/pattern_banner.dart';
import 'package:inawl_app/widgets/custom_button.dart';
import 'package:inawl_app/widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        // TODO: Process the selected image for Inaul fabric identification
        debugPrint('Image selected from gallery: ${image.path}');
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
      body: Column(
        children: [
          // Top patterned image
          const PatternBanner(isTop: true),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppConstants.spacingExtraLarge),
                    Text(
                      'Welcome!',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingXXL),

                    // Section Title
                    const SectionTitle(
                      title: 'Inaul Identifier',
                      subtitle: 'Identify the Inaul textile pattern',
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),

                    // Buttons
                    CustomButton(
                      text: 'Scan Inaul Fabric',
                      onPressed: () => AppRoutes.navigateToCamera(context),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    CustomButton(
                      text: 'Upload Inaul Image',
                      onPressed: _pickImageFromGallery,
                    ),
                    const SizedBox(height: AppConstants.spacingXXXL),

                    // More Section
                    const SectionTitle(
                      title: 'More',
                      subtitle: 'Learn more about Inaul!',
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),

                    CustomButton(
                      text: 'Browse Library',
                      onPressed: () => AppRoutes.navigateToLibrary(context),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    CustomButton(
                      text: 'About Inaul',
                      onPressed: () => AppRoutes.navigateToAbout(context),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom patterned image
          const PatternBanner(isTop: false),
        ],
      ),
    );
  }
}
