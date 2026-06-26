import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final String? backgroundImagePath = 'assets/images/background.jpg';
  
  final Widget child;
  final Widget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final BoxFit? imageFit;

  const BackgroundScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.imageFit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: appBar != null 
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: appBar!,
            )
          : null,
      body: Stack(
        children: [
          // Background Image - 100% Visibility in the main viewing area
          if (backgroundImagePath != null)
            Positioned.fill(
              child: Image.asset(
                backgroundImagePath!,
                fit: imageFit ?? BoxFit.cover,
              ),
            ),
          
          // Atmospheric Gradient: Protects edges and improves text contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.15, 0.85, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.5), // Top protection
                    Colors.black.withOpacity(0.2), // Subtle middle overlay
                    Colors.black.withOpacity(0.2), // Subtle middle overlay
                    Colors.black.withOpacity(0.6), // Bottom protection
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: child,
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
