import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  // Content from ref/adventist-hymnarium/privacy-policy.md
  final String _privacyPolicyMarkdown = """
# Privacy Policy for Adventist Hymnarium

Last updated: May 1, 2025

## Overview

Adventist Hymnarium is committed to protecting your privacy. This privacy policy explains that we do not collect, use, or share any personal information.

## Data Collection

Adventist Hymnarium does not collect, store, or transmit any personal information. The app:
- Does not require user accounts
- Does not track user activity
- Does not collect usage statistics
- Does not use analytics
- Does not share any information with third parties

## Local Storage

Any app preferences (such as favorites, recent hymns, text size) are stored locally on your device and are never transmitted to any servers.

## Third-Party Services

The app uses a dedicated server only to serve hymn audio and sheet music files. No personal information is transmitted during these requests.

## Changes to This Policy

We may update this privacy policy from time to time. Any changes will be posted in the app's App Store listing and in this document.

## Contact

If you have any questions about this privacy policy, please contact:
info@adventisthymnarium.app

## Legal Rights

As we do not collect any personal information, there is no personal data to access, modify, or delete. Your use of the app is completely private. 
""";

  // Helper to build Text widgets with consistent centering and styling
  Widget _buildText(BuildContext context, String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Spacing below each text block
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String text, TextStyle? style) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 6.0, left: 20.0, right: 20.0), 
       child: Text(
          text,
          style: style,
          textAlign: TextAlign.center, 
       ),
     );
  }

  // Helper function to launch mailto link
  Future<void> _launchEmail(BuildContext context, String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      // You could add subject/body here if desired
      // query: 'subject=App Feedback&body=Hello,',
    );

    if (!await launchUrl(emailLaunchUri)) {
      print('Could not launch $emailLaunchUri');
      // Show error SnackBar if launch fails
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Could not open email app for $email')),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final h1Style = textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold);
    final h2Style = textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);
    final bodyStyle = textTheme.bodyMedium?.copyWith(height: 1.4);
    final listStyle = textTheme.bodyMedium?.copyWith(height: 1.3);
    final linkStyle = bodyStyle?.copyWith(
        color: colorScheme.primary, // Use primary color for link
        decoration: TextDecoration.underline,
        decorationColor: colorScheme.primary, // Underline color
    );

    final lines = _privacyPolicyMarkdown.trim().split('\n');
    List<Widget> contentWidgets = [];
    const String targetEmail = "info@adventisthymnarium.app";

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.contains(targetEmail)) {
        // Special handling for the line containing the email
        final parts = line.split(targetEmail);
        final beforeText = parts.isNotEmpty ? parts[0] : '';
        final afterText = parts.length > 1 ? parts[1] : ''; // Handle if email is at the end

        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: RichText(
              textAlign: TextAlign.center, // Center the whole RichText block
              text: TextSpan(
                style: bodyStyle, // Default style for the line
                children: <TextSpan>[
                  TextSpan(text: beforeText),
                  TextSpan(
                    text: targetEmail,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _launchEmail(context, targetEmail),
                  ),
                  TextSpan(text: afterText),
                ],
              ),
            ),
          )
        );
      } else if (line.startsWith('## ')) {
        contentWidgets.add(const SizedBox(height: 16));
        contentWidgets.add(_buildText(context, line.substring(3), h2Style));
      } else if (line.startsWith('# ')) {
         contentWidgets.add(const SizedBox(height: 24));
         contentWidgets.add(_buildText(context, line.substring(2), h1Style));
      } else if (line.startsWith('- ')) {
         contentWidgets.add(_buildListItem(context, line.substring(2), listStyle));
      } else {
         contentWidgets.add(_buildText(context, line, bodyStyle));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Information'),
      ),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(16.0),
         child: Center( 
            child: ConstrainedBox( 
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: contentWidgets,
                ),
            ),
         )
      ),
    );
  }
} 