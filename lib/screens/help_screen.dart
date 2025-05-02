import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Text(
              'How to Use',
              style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
            ),
          ),
          const SizedBox(height: 20),
          _buildHelpItem(
            context,
            title: "Finding Hymns",
            description: "Use the number pad to enter a hymn number directly, or use the search feature to find hymns by title or lyrics.",
          ),
          const SizedBox(height: 15),
          _buildHelpItem(
            context,
            title: "Thematic Index",
            description: "Browse hymns by theme using the Index tab. Hymns are categorized by topic for easy reference.",
          ),
          const SizedBox(height: 15),
          _buildHelpItem(
            context,
            title: "Favorites",
            description: "Tap the heart icon while viewing a hymn to add it to your favorites for quick access.",
          ),
           const SizedBox(height: 15),
          _buildHelpItem(
            context,
            title: "Settings",
            description: "Customize font size, verse numbers, and other display preferences to your liking.",
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, {required String title, required String description}) {
     final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 