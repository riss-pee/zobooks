import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? blur;
  final double? opacity;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final bool showShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur,
    this.opacity,
    this.borderRadius = 24.0,
    this.color,
    this.gradient,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Apply the theme guidelines if not overridden
    final effectiveBlur = blur ?? (isDark ? 20.0 : 20.0);
    final effectiveOpacity = opacity ?? (isDark ? 0.08 : 0.6);
    
    final borderColor = isDark ? const Color(0xFFB3B3B3) : const Color(0xFFD4D4D4);
    final borderWidth = isDark ? 0.5 : 1.0;
    
    final effectiveBorder = border ?? Border.all(
      color: borderColor,
      width: borderWidth,
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 40 : 15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: effectiveBorder,
              color: (color ?? (isDark ? Colors.black : Colors.white)).withAlpha((255 * effectiveOpacity).toInt()),
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
