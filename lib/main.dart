import 'package:flutter/material.dart';
import 'package:inawl_app/core/constants/app_constants.dart';
import 'package:inawl_app/core/theme/app_theme.dart';
import 'package:inawl_app/core/routes/app_routes.dart';
import 'package:inawl_app/services/model_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the TensorFlow Lite model
  try {
    await ModelService.loadModel();
    debugPrint('✓ Model initialized successfully');
  } catch (e) {
    debugPrint('✗ Error loading model: $e');
    debugPrint('App will run but pattern identification will not work');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.home,
    );
  }
}
