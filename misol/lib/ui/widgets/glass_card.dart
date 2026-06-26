import 'package:flutter/material.dart';
import 'dart:ui';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 50, // Maximized blur for content diffusion
    this.borderRadius,
    this.padding,
    this.border,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(24);

    return Container(
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 40,
            offset: const Offset(0, 15),
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Increased opacity to 0.5 for better text legibility and contrast
              color: color ?? (isDark
                  ? Colors.black.withOpacity(0.5) 
                  : Colors.white.withOpacity(0.7)),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1.2,
              ),
              borderRadius: defaultBorderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
