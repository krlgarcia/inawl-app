import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/widgets/pattern_banner.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                    'About Inaul',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingExtraLarge),

                  // Scrollable text content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _getAboutContent(),
                        style: Theme.of(context).textTheme.bodyLarge,
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

  String _getAboutContent() {
    return 'Inaul is a traditional handwoven textile from the Maguindanao people of Mindanao, Philippines. '
        'This intricate fabric is characterized by its vibrant colors and geometric patterns, '
        'which hold deep cultural significance and represent the rich heritage of the Maranao and Maguindanao communities.\n\n'
        'The art of weaving Inaul has been passed down through generations, with each pattern telling '
        'a unique story or representing specific cultural symbols. The textile is traditionally made '
        'from cotton or silk threads, carefully dyed using natural materials to achieve the brilliant '
        'colors that Inaul is known for.\n\n'
        'Today, Inaul continues to be an important part of Filipino cultural identity and is recognized '
        'as one of the country\'s most treasured traditional crafts. Through this app, we aim to help '
        'preserve and promote awareness of this beautiful textile art form by providing tools to '
        'identify different Inaul patterns and learn about their cultural significance.';
  }
}
