import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';

class PatternBanner extends StatelessWidget {
  final bool isTop;
  
  const PatternBanner({
    super.key,
    this.isTop = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: isTop ? Radius.zero : Radius.zero,
        topRight: isTop ? Radius.zero : Radius.zero,
        bottomLeft: isTop ? Radius.zero : Radius.zero,
        bottomRight: isTop ? Radius.zero : Radius.zero,
      ),
      child: Image.asset(
        AppConstants.patternImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: AppConstants.bannerHeight,
      ),
    );
  }
}