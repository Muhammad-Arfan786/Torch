import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/color_temperature.dart';

class ColorTemperatureSlider extends StatelessWidget {
  final double temperature;
  final ValueChanged<double> onChanged;
  final bool enabled;

  const ColorTemperatureSlider({
    super.key,
    required this.temperature,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.thermostat,
                  color: enabled ? AppColors.textSecondary : AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'COLOR TEMPERATURE',
                  style: TextStyle(
                    color: enabled ? AppColors.textSecondary : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ColorTemperature.kelvinToColor(temperature)
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorTemperature.kelvinToColor(temperature)
                      .withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                '${temperature.round()}K',
                style: TextStyle(
                  color: enabled
                      ? ColorTemperature.kelvinToColor(temperature)
                      : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Gradient track slider
        Container(
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                ColorTemperature.kelvinToColor(2700),
                ColorTemperature.kelvinToColor(3500),
                ColorTemperature.kelvinToColor(4500),
                ColorTemperature.kelvinToColor(5500),
                ColorTemperature.kelvinToColor(6500),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 36,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbShape: _TemperatureThumbShape(),
              overlayShape: SliderComponentShape.noOverlay,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: temperature,
              onChanged: enabled ? onChanged : null,
              min: 2700,
              max: 6500,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Warm',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                ColorTemperature.getTemperatureName(temperature),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Cool',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemperatureThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer circle (white border)
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 12, outerPaint);

    // Inner circle (shadow)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, 10, shadowPaint);

    // Inner circle (fill)
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 10, innerPaint);

    // Center dot
    final dotPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, dotPaint);
  }
}

class ColorTemperaturePresets extends StatelessWidget {
  final double currentTemperature;
  final ValueChanged<double> onPresetSelected;

  const ColorTemperaturePresets({
    super.key,
    required this.currentTemperature,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ColorTemperature.presets.map((preset) {
        final isSelected =
            (currentTemperature - preset.kelvin).abs() < 100;

        return GestureDetector(
          onTap: () => onPresetSelected(preset.kelvin),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorTemperature.kelvinToColor(preset.kelvin)
                      .withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? ColorTemperature.kelvinToColor(preset.kelvin)
                        .withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Text(
              preset.name,
              style: TextStyle(
                color: isSelected
                    ? ColorTemperature.kelvinToColor(preset.kelvin)
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
