import 'package:flutter/material.dart';
import 'package:inawl_app/widgets/back_button.dart' as custom;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // Back button
                  const custom.BackButtonWidget(),

                  const SizedBox(height: 10),
                  const Text(
                    'About Inaul',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Scrollable text content
                  const Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
                            'Quisque faucibus ex sapien vitae pellentesque sem placerat. '
                            'In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. '
                            'Pulvinar vivamus fringilla lacus nec metus bibendum egestas. '
                            'Lacinia massa nisl malesuada lacinia integer nunc posuere. '
                            'Ut hendrerit semper vel class aptent taciti sociosqu. '
                            'Ad litora torquent per conubia nostra inceptos himenaeos.\n\n'
                            'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
                            'Quisque faucibus ex sapien vitae pellentesque sem placerat. '
                            'In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. '
                            'Pulvinar vivamus fringilla lacus nec metus bibendum egestas. '
                            'Lacinia massa nisl malesuada lacinia integer nunc posuere. '
                            'Ut hendrerit semper vel class aptent taciti sociosqu. '
                            'Ad litora torquent per conubia nostra inceptos himenaeos.\n\n'
                            'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
                            'Quisque faucibus ex sapien vitae pellentesque sem placerat. '
                            'In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. '
                            'Pulvinar vivamus fringilla lacus nec metus bibendum egestas. '
                            'Lacinia massa nisl malesuada lacinia integer nunc posuere. '
                            'Ut hendrerit semper vel class aptent taciti sociosqu. '
                            'Ad litora torquent per conubia nostra inceptos himenaeos.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
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
