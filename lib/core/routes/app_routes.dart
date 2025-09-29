import 'package:flutter/material.dart';
import 'package:inawl_app/screens/home_screen.dart';
import 'package:inawl_app/screens/library_screen.dart';
import 'package:inawl_app/screens/about_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String library = '/library';
  static const String about = '/about';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case library:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
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
}