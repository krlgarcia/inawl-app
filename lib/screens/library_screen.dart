import 'package:flutter/material.dart';
import 'package:inawl_app/widgets/back_button.dart' as custom;

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top patterned placeholder
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.brown[300],
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/gorilla.jpg', // <-- TOP pattern image file
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

                  // Grid placeholders
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                      ),
                      itemCount: 12, // number of placeholders
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text("Image"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom patterned placeholder
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.brown[300],
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/gorilla.jpg', // <-- TOP pattern image file
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
