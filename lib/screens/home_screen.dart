import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/torch_service.dart';
import '../services/settings_service.dart';
import '../services/shake_detection_service.dart';
import '../widgets/glassmorphic_container.dart';
import 'screen_torch.dart';
import 'compass_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shakeService = context.read<ShakeDetectionService>();
    final settingsService = context.read<SettingsService>();

    if (state == AppLifecycleState.paused) {
      shakeService.stopListening();
    } else if (state == AppLifecycleState.resumed) {
      if (settingsService.shakeEnabled) {
        shakeService.startListening();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final torchService = context.watch<TorchService>();
    final settingsService = context.watch<SettingsService>();
    final shakeService = context.watch<ShakeDetectionService>();

    final isTorchOn = torchService.mode == TorchMode.on;
    final isStrobe = torchService.mode == TorchMode.strobe;
    final isSos = torchService.mode == TorchMode.sos;
    final isActive = isTorchOn || isStrobe || isSos;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isActive
                ? AppColors.activeGradient
                : AppColors.inactiveGradient,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Ambient background glow when active
              if (isActive)
                Positioned(
                  top: -150,
                  left: -50,
                  right: -50,
                  height: 500,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentOrange.withValues(alpha: 0.4),
                          AppColors.accentOrange.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        center: Alignment.topCenter,
                        radius: 1.0,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),

              Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TORCH',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        Row(
                          children: [
                            // Compass button
                            GlassmorphicButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CompassScreen(),
                                  ),
                                );
                              },
                              icon: Icons.explore_outlined,
                              size: 48,
                              iconSize: 24,
                            ),
                            const SizedBox(width: 12),
                            // Screen light button
                            GlassmorphicButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ScreenTorch(),
                                  ),
                                );
                              },
                              icon: Icons.wb_sunny_outlined,
                              size: 48,
                              iconSize: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Main Power Button
                  Center(
                    child: GlassmorphicPowerButton(
                      onPressed: () => torchService.toggleTorch(),
                      isActive: isActive,
                      size: 200,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mode indicator
                  AnimatedOpacity(
                    opacity: isActive ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isStrobe
                          ? 'STROBE MODE'
                          : isSos
                              ? 'SOS MODE'
                              : 'ON',
                      style: TextStyle(
                        color: AppColors.accentOrange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Controls Panel
                  GlassmorphicContainer(
                    blur: 15,
                    opacity: 0.08,
                    borderOpacity: 0.15,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      children: [
                        // Strobe Control
                        _buildStrobeControl(
                          isStrobe: isStrobe,
                          isSos: isSos,
                          torchService: torchService,
                        ),

                        const SizedBox(height: 20),

                        // SOS Control
                        _buildControlRow(
                          icon: Icons.sos,
                          label: 'SOS SIGNAL',
                          isActive: isSos,
                          child: Switch(
                            value: isSos,
                            onChanged: (val) => torchService.setSosMode(val),
                            activeColor: AppColors.accentOrange,
                            activeTrackColor:
                                AppColors.accentOrange.withValues(alpha: 0.3),
                            inactiveThumbColor: AppColors.textMuted,
                            inactiveTrackColor:
                                AppColors.textMuted.withValues(alpha: 0.3),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Shake to Toggle
                        _buildControlRow(
                          icon: Icons.vibration,
                          label: 'SHAKE TO TOGGLE',
                          isActive: settingsService.shakeEnabled,
                          child: Switch(
                            value: settingsService.shakeEnabled,
                            onChanged: (val) {
                              settingsService.setShakeEnabled(val);
                              if (val) {
                                shakeService.startListening();
                              } else {
                                shakeService.stopListening();
                              }
                            },
                            activeColor: AppColors.accentOrange,
                            activeTrackColor:
                                AppColors.accentOrange.withValues(alpha: 0.3),
                            inactiveThumbColor: AppColors.textMuted,
                            inactiveTrackColor:
                                AppColors.textMuted.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(
                        begin: 0.3,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlRow({
    required IconData icon,
    required String label,
    required bool isActive,
    required Widget child,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.accentOrange : AppColors.textMuted,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.accentOrange : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildStrobeControl({
    required bool isStrobe,
    required bool isSos,
    required TorchService torchService,
  }) {
    return Row(
      children: [
        Icon(
          Icons.bolt,
          color: isStrobe ? AppColors.accentOrange : AppColors.textMuted,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          'STROBE',
          style: TextStyle(
            color: isStrobe ? AppColors.accentOrange : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: isStrobe
                  ? AppColors.accentOrange
                  : AppColors.textMuted,
              inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.3),
              thumbColor: isStrobe ? AppColors.accentOrange : AppColors.textMuted,
              overlayColor: AppColors.accentOrange.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: (1000 - torchService.strobeFrequency) / 950.0,
              onChanged: isSos
                  ? null
                  : (val) {
                      torchService.updateStrobeFrequency(val);
                      if (!isStrobe && !isSos) {
                        torchService.setStrobeMode(true);
                      }
                    },
            ),
          ),
        ),
        const SizedBox(width: 12),
        GlassmorphicButton(
          onPressed: () => torchService.setStrobeMode(!isStrobe),
          icon: Icons.bolt,
          isActive: isStrobe,
          size: 44,
          iconSize: 22,
        ),
      ],
    );
  }
}
