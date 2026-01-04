import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderWidth;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderOpacity = 0.2,
    this.borderRadius,
    this.padding,
    this.margin,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.glassWhite.withValues(alpha: opacity),
              borderRadius: radius,
              border: Border.all(
                color: AppColors.glassWhite.withValues(alpha: borderOpacity),
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassmorphicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;
  final double size;
  final IconData icon;
  final double iconSize;
  final Color? activeColor;

  const GlassmorphicButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isActive = false,
    this.size = 60,
    this.iconSize = 28,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.accentOrange;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? color.withValues(alpha: 0.3)
                    : AppColors.glassWhite.withValues(alpha: 0.1),
                border: Border.all(
                  color: isActive
                      ? color.withValues(alpha: 0.5)
                      : AppColors.glassWhite.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: isActive ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicPowerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;
  final double size;

  const GlassmorphicPowerButton({
    super.key,
    required this.onPressed,
    this.isActive = false,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accentOrange.withValues(alpha: 0.6),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: AppColors.accentOrange.withValues(alpha: 0.3),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive
                      ? [
                          AppColors.accentOrange.withValues(alpha: 0.8),
                          AppColors.glowOrange.withValues(alpha: 0.6),
                        ]
                      : [
                          AppColors.glassWhite.withValues(alpha: 0.15),
                          AppColors.glassWhite.withValues(alpha: 0.05),
                        ],
                ),
                border: Border.all(
                  color: isActive
                      ? AppColors.glowOrange.withValues(alpha: 0.8)
                      : AppColors.glassWhite.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.power_settings_new,
                size: size * 0.4,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
