import 'package:flutter/material.dart';
import '../ui/widgets/background_scaffold.dart';
import '../ui/widgets/glass_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo with glass effect
            GlassCard(
              blur: 20,
              borderRadius: BorderRadius.circular(35),
              color: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 80,
                height: 80,
                child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 50),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Misol',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1.5,
                shadows: [Shadow(color: Colors.black45, blurRadius: 15)],
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle with protective glass tint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Your schedule, beautifully organized.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.95),
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A80F0).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A80F0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'GET STARTED',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
