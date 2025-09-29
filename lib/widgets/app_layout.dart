import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/widgets/pattern_banner.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const AppLayout({
    super.key,
    required this.child,
    this.showBackButton = false,
  });

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
              child: child,
            ),
          ),

          // Bottom patterned banner
          const PatternBanner(isTop: false),
        ],
      ),
    );
  }
}