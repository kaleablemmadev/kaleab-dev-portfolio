import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../ui/widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _settings.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: [Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 10)],
                ),
              ),
              TextButton(
                onPressed: () => _settings.resetSettings(),
                child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
              color: Colors.black.withOpacity(0.25),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionHeader('Calendar'),
                  _buildDropdownSetting(
                    'Start of Week',
                    _settings.startOfWeek,
                    ['Sunday', 'Monday'],
                    (val) => _settings.setStartOfWeek(val!),
                    Icons.calendar_today_outlined,
                  ),
                  _buildDropdownSetting(
                    'Time Format',
                    _settings.timeFormat,
                    ['12h', '24h'],
                    (val) => _settings.setTimeFormat(val!),
                    Icons.access_time,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Notifications'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Reminders', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    value: _settings.notifications,
                    activeColor: const Color(0xFF4A80F0),
                    onChanged: (val) => _settings.setNotifications(val),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Support'),
                  _buildActionTile('User Manual (Misol)', Icons.help_outline, () => Navigator.pushNamed(context, '/about')),
                  _buildActionTile('Privacy Policy', Icons.privacy_tip_outlined, () => Navigator.pushNamed(context, '/privacy')),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _buildDropdownSetting(String title, String value, List<String> options, Function(String?) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF1E1E1E),
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
              style: const TextStyle(color: Color(0xFF4A80F0), fontWeight: FontWeight.w700),
              items: options.map((String opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
