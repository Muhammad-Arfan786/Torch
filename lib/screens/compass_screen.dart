import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/compass_service.dart';
import '../services/torch_service.dart';
import '../widgets/compass_widget.dart';
import '../widgets/glassmorphic_container.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompassService>().startListening();
    });
  }

  @override
  void dispose() {
    // Note: We don't stop listening here as the service is shared
    // and might be used elsewhere
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compassService = context.watch<CompassService>();
    final torchService = context.watch<TorchService>();
    final isTorchOn = torchService.mode != TorchMode.off;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isTorchOn
                ? AppColors.activeGradient
                : AppColors.inactiveGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GlassmorphicContainer(
                      blur: 10,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(12),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'COMPASS',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Heading display
              if (compassService.isAvailable) ...[
                Text(
                  '${compassService.heading?.toStringAsFixed(0) ?? '--'}°',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    color: AppColors.textPrimary,
                    letterSpacing: -2,
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 8),
                Text(
                  compassService.cardinalDirection,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                    letterSpacing: 4,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                const SizedBox(height: 8),
                Text(
                  compassService.getFullCardinalDirection(compassService.heading),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              ] else ...[
                const Icon(
                  Icons.explore_off,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Compass not available',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This device may not have a magnetometer',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Compass widget
              if (compassService.isAvailable)
                CompassWidget(
                  heading: compassService.heading,
                  size: 280,
                ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),

              const Spacer(),

              // Bottom torch toggle
              GlassmorphicContainer(
                blur: 15,
                opacity: 0.1,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TORCH',
                          style: TextStyle(
                            color: isTorchOn
                                ? AppColors.accentOrange
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTorchOn ? 'On' : 'Off',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    GlassmorphicButton(
                      onPressed: () => torchService.toggleTorch(),
                      icon: Icons.flashlight_on,
                      isActive: isTorchOn,
                      size: 56,
                    ),
                  ],
                ),
              ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOut),
            ],
          ),
        ),
      ),
    );
  }
}
