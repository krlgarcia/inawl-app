import 'package:flutter/material.dart';
import 'package:inawl_app/screens/library_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top patterned image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
            child: Image.asset(
              'assets/images/gorilla.jpg', // <-- TOP pattern image file
              fit: BoxFit.cover,
              width: double.infinity,
              height: 80,
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Section Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Inaul Identifier',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Identify the Inaul textile pattern',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Buttons
                    _buildButton('Scan Inaul Fabric'),
                    const SizedBox(height: 10),
                    _buildButton('Upload Inaul Image'),
                    const SizedBox(height: 45),

                    // More Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'More',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Learn more about Inaul!',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildButton('Browse Library', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LibraryScreen()),
                      );
                    }),

                    const SizedBox(height: 10),

                    _buildButton('About Inaul'),
                  ],
                ),
              ),
            ),
          ),

          // Bottom patterned image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.zero,
            ),
            child: Image.asset(
              'assets/images/gorilla.jpg', // <-- BOTTOM pattern image file
              fit: BoxFit.cover,
              width: double.infinity,
              height: 80,
            ),
          ),
        ],
      ),
    );
  }

  // Button builder
  static Widget _buildButton(String text, [VoidCallback? onPressed]) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD17A45),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed ?? () {}, // ✅ fallback to empty function
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
