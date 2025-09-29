import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/core/theme/app_theme.dart';

class BackButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const BackButtonWidget({
    super.key,
    this.text = 'Back',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.backButtonHorizontalPadding,
            vertical: AppConstants.backButtonVerticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.backButtonBorderRadius),
          ),
        ),
        onPressed: onPressed ?? () => Navigator.pop(context),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
