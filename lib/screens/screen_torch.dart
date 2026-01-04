import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../constants/app_colors.dart';
import '../services/settings_service.dart';
import '../utils/color_temperature.dart';
import '../widgets/brightness_slider.dart';
import '../widgets/color_temperature_slider.dart';
import '../widgets/glassmorphic_container.dart';

class ScreenTorch extends StatefulWidget {
  const ScreenTorch({super.key});

  @override
  State<ScreenTorch> createState() => _ScreenTorchState();
}

class _ScreenTorchState extends State<ScreenTorch> {
  bool _showControls = false;
  late double _brightness;
  late double _colorTemperature;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    // Load saved settings
    final settings = context.read<SettingsService>();
    _brightness = settings.screenBrightness;
    _colorTemperature = settings.colorTemperature;
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Color get _screenColor {
    return ColorTemperature.kelvinToColorWithBrightness(
      _colorTemperature,
      _brightness,
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _updateBrightness(double value) {
    setState(() {
      _brightness = value;
    });
    context.read<SettingsService>().setScreenBrightness(value);
  }

  void _updateColorTemperature(double value) {
    setState(() {
      _colorTemperature = value;
    });
    context.read<SettingsService>().setColorTemperature(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleControls,
        onLongPress: () => Navigator.pop(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: double.infinity,
          color: _screenColor,
          child: SafeArea(
            child: Stack(
              children: [
                // Instructions (shown when controls hidden)
                if (!_showControls)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 48,
                          color: _getContrastColor().withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap for controls',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _getContrastColor().withValues(alpha: 0.4),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Long press to exit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _getContrastColor().withValues(alpha: 0.3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                // Control panel (shown when tapped)
                if (_showControls)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {}, // Prevent tap from closing controls
                      child: GlassmorphicContainer(
                        blur: 20,
                        opacity: 0.15,
                        borderOpacity: 0.25,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Drag handle
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Title
                            Row(
                              children: [
                                Icon(
                                  Icons.wb_sunny,
                                  color: AppColors.accentOrange,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'SCREEN LIGHT',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Brightness slider
                            BrightnessSlider(
                              value: _brightness,
                              onChanged: _updateBrightness,
                            ),
                            const SizedBox(height: 24),

                            // Color temperature slider
                            ColorTemperatureSlider(
                              temperature: _colorTemperature,
                              onChanged: _updateColorTemperature,
                            ),
                            const SizedBox(height: 24),

                            // Quick presets
                            ColorTemperaturePresets(
                              currentTemperature: _colorTemperature,
                              onPresetSelected: _updateColorTemperature,
                            ),
                            const SizedBox(height: 16),

                            // Close button
                            TextButton(
                              onPressed: _toggleControls,
                              child: Text(
                                'TAP ANYWHERE TO CLOSE',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(
                          begin: 1,
                          duration: 300.ms,
                          curve: Curves.easeOut,
                        ),
                  ),

                // Back button (always visible)
                Positioned(
                  top: 16,
                  left: 16,
                  child: GlassmorphicContainer(
                    blur: 10,
                    opacity: 0.1,
                    borderRadius: BorderRadius.circular(12),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: _getContrastColor().withValues(alpha: 0.7),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get a contrasting color for text based on current screen color
  Color _getContrastColor() {
    final luminance = _screenColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
