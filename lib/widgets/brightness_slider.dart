import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BrightnessSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final bool enabled;
  final double min;
  final double max;

  const BrightnessSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.min = 0.1,
    this.max = 1.0,
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
                  Icons.brightness_medium,
                  color: enabled ? AppColors.textSecondary : AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'BRIGHTNESS',
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
                color: AppColors.accentOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: enabled ? AppColors.accentOrange : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.accentOrange,
            inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.3),
            thumbColor: AppColors.accentOrange,
            overlayColor: AppColors.accentOrange.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 6,
            disabledActiveTrackColor: AppColors.textMuted,
            disabledInactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.2),
            disabledThumbColor: AppColors.textMuted,
          ),
          child: Slider(
            value: value,
            onChanged: enabled ? onChanged : null,
            min: min,
            max: max,
          ),
        ),
        // Min/Max labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.brightness_low,
                color: AppColors.textMuted,
                size: 16,
              ),
              Icon(
                Icons.brightness_high,
                color: AppColors.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
