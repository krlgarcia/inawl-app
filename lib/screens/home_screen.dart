import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/core/routes/app_routes.dart';
import 'package:inawl_app/widgets/pattern_banner.dart';
import 'package:inawl_app/widgets/custom_button.dart';
import 'package:inawl_app/widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    const CustomButton(text: 'Scan Inaul Fabric'),
                    const SizedBox(height: AppConstants.spacingMedium),
                    const CustomButton(text: 'Upload Inaul Image'),
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
