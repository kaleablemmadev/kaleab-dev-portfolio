import 'package:flutter/material.dart';
import '../ui/widgets/background_scaffold.dart';
import '../ui/widgets/glass_card.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GlassCard(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                color: Colors.black.withOpacity(0.35),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Privacy Matters',
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'At Misol, we take your privacy seriously. This app is designed to work entirely offline for your security.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9), 
                          height: 1.5,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('1. Data Collection'),
                      const SizedBox(height: 8),
                      Text(
                        'Misol does not collect any personal data. All your events and settings are stored locally on your device.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85), 
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('2. Permissions'),
                      const SizedBox(height: 8),
                      Text(
                        'The app may request notification permissions only to provide you with event reminders. You can disable this at any time in the settings.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85), 
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('3. Third Parties'),
                      const SizedBox(height: 8),
                      Text(
                        'We do not share any information with third parties because we do not have access to it. Your schedule stays between you and your phone.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85), 
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Last updated: May 2024',
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold, 
        color: Colors.white,
        shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
      ),
    );
  }
}
