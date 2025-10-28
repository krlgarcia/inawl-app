import 'package:flutter/material.dart';
import 'package:inawl_app/screens/home_screen.dart';
import 'package:inawl_app/screens/library_screen.dart';
import 'package:inawl_app/screens/about_screen.dart';
import 'package:inawl_app/screens/camera_screen.dart';
import 'package:inawl_app/screens/pattern_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String library = '/library';
  static const String about = '/about';
  static const String camera = '/camera';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case library:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case camera:
        return MaterialPageRoute(builder: (_) => const CameraScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  static void navigateToLibrary(BuildContext context) {
    Navigator.pushNamed(context, library);
  }
  
  static void navigateToAbout(BuildContext context) {
    Navigator.pushNamed(context, about);
  }
  
  static void navigateToCamera(BuildContext context) {
    Navigator.pushNamed(context, camera);
  }
  
  static void navigateToPattern(
    BuildContext context,
    String patternName,
    String imagePath, {
    String? capturedImagePath,
    String? confidence,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatternScreen(
          patternName: patternName,
          imagePath: imagePath,
          capturedImagePath: capturedImagePath,
          confidence: confidence,
        ),
      ),
    );
  }
}