import 'package:flutter/material.dart';
import '../ui/widgets/background_scaffold.dart';
import '../ui/widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                  'Misol (Manual)',
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
                      _buildManualSection(
                        'Introduction',
                        'Welcome to Misol! Your elegant companion for managing time and tasks. Misol means "Example" or "Manual" in Amharic, reflecting our goal to be the standard for your daily planning.',
                      ),
                      _buildManualSection(
                        'Getting Started',
                        'Navigate between Month, Week, and Day views using the top capsule buttons. Use the bottom navigation bar to switch between Calendar, Tasks, and Settings.',
                      ),
                      _buildManualSection(
                        'Creating Events',
                        'Tap any date on the calendar to select it, then tap the + button (if available) or long press to add an event. You can set titles, locations, descriptions, and custom colors.',
                      ),
                      _buildManualSection(
                        'Managing Tasks',
                        'Go to the Tasks tab to manage your to-do list. Tasks support priorities (Low, Medium, High) and can be marked complete by tapping the circle. Tasks with due dates appear in the daily section.',
                      ),
                      _buildManualSection(
                        'Reminders & Repeat',
                        'Both events and tasks support reminders. You can set them to fire minutes, hours, or even a day before. Use the Repeat option for recurring schedules like weekly meetings. Snooze functionality allows you to postpone reminders.',
                      ),
                      _buildManualSection(
                        'Calendar Views',
                        '• Month View: See the entire month with event indicators\n• Week View: Detailed weekly schedule\n• Day View: Time-based timeline with hourly slots\n• Events are color-coded for easy identification',
                      ),
                      _buildManualSection(
                        'Settings',
                        'Customize your experience in the Settings tab:\n• Start of Week: Choose Sunday or Monday\n• Time Format: Toggle between 12h and 24h\n• Notifications: Enable or disable reminders',
                      ),
                      _buildManualSection(
                        'Tips & Tricks',
                        '• Swipe left on an event to delete it\n• Long press a day in the calendar to see a quick agenda\n• Tapping a day in the Month view takes you to the Daily Section\n• Overdue tasks are highlighted in red\n• Tasks are automatically sorted by due date',
                      ),
                      _buildFAQSection(),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          '© 2024 Misol App. All rights reserved.',
                          style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                        ),
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

  Widget _buildManualSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF4A80F0),
              shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9), 
              height: 1.5,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Frequently Asked Questions',
          style: const TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            color: Color(0xFF4A80F0),
            shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'How do I create a repeating event?',
          'When creating or editing an event, scroll to the "Reminders & Repeat" section. Tap on "Repeat" and select your preferred frequency (Daily, Weekly, Monthly, Yearly, or Custom).',
        ),
        _buildFAQItem(
          'Can I set multiple reminders?',
          'Currently, each event or task supports a single reminder. You can choose when the reminder fires (at time, 5/10/15/30 minutes before, 1/2 hours before, or 1 day before).',
        ),
        _buildFAQItem(
          'What happens when I complete a repeating task?',
          'When you mark a repeating task as complete, the next instance is automatically generated based on the repeat configuration.',
        ),
        _buildFAQItem(
          'How do I change the calendar start day?',
          'Go to Settings > Start of Week and choose between Sunday or Monday. The calendar layout updates immediately.',
        ),
        _buildFAQItem(
          'Are my events and tasks synced?',
          'Currently, data is stored locally on your device. Future versions may include cloud sync capabilities.',
        ),
        _buildFAQItem(
          'How do I delete an event or task?',
          'Swipe left on an event card to delete it. For tasks, tap the delete icon on the right side of the task item.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
