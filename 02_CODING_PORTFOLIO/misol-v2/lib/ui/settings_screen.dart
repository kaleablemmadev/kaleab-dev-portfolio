import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
            ),
          ),
        ),
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            shadows: [
              Shadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: "Reminders",
            subtitle: "Manage event notifications",
            trailing: Switch(
              value: true,
              onChanged: (val) {},
              activeThumbColor: AppTheme.primaryViolet,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            icon: Icons.image_outlined,
            title: "Customize Your Background",
            subtitle: "Choose a new photo for your home screen",
            trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryViolet),
            onTap: () {
              // Implementation to pick image
            },
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: "About misol",
            subtitle: "Version 1.0.0",
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.white.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.05),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDark),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryViolet.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryViolet),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
