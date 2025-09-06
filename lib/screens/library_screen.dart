import 'package:flutter/material.dart';
import 'package:inawl_app/widgets/back_button.dart' as custom;

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of your images
    final List<String> images = [
      'assets/images/gorilla.jpg',
      'assets/images/aloy1.png',
      'assets/images/aloy2.png',
      'assets/images/hther.jpg',
      'assets/images/nee-san.jpg',
      'assets/images/speed.jpg',
      'assets/images/tunnel.jpg',
      'assets/images/burjer.jpg',
      'assets/images/bxw.jpg',
      'assets/images/ruwoghxy.jpg',
      'assets/images/zamn.png',
      'assets/images/isekai.jpg',
    ];

    return Scaffold(
      body: Column(
        children: [
          // Top patterned banner
          ClipRRect(
            child: Image.asset(
              'assets/images/gorilla.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 80,
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  const custom.BackButtonWidget(),

                  const SizedBox(height: 10),
                  const Text(
                    'Inaul Library',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Browse through our growing Inaul Library!',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // Grid of actual images
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom patterned banner
          ClipRRect(
            child: Image.asset(
              'assets/images/gorilla.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 80,
            ),
          ),
        ],
      ),
    );
  }
}
