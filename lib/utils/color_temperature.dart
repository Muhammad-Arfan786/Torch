import 'dart:math';
import 'package:flutter/material.dart';

class ColorTemperature {
  /// Converts Kelvin temperature to RGB color
  /// Range: 1000K (warm candle) to 10000K (cool blue sky)
  /// Algorithm based on Tanner Helland's work
  static Color kelvinToColor(double kelvin) {
    kelvin = kelvin.clamp(1000, 10000);
    final temp = kelvin / 100;

    double red, green, blue;

    // Red calculation
    if (temp <= 66) {
      red = 255;
    } else {
      red = temp - 60;
      red = 329.698727446 * pow(red, -0.1332047592);
      red = red.clamp(0, 255);
    }

    // Green calculation
    if (temp <= 66) {
      green = temp;
      green = 99.4708025861 * log(green) - 161.1195681661;
      green = green.clamp(0, 255);
    } else {
      green = temp - 60;
      green = 288.1221695283 * pow(green, -0.0755148492);
      green = green.clamp(0, 255);
    }

    // Blue calculation
    if (temp >= 66) {
      blue = 255;
    } else if (temp <= 19) {
      blue = 0;
    } else {
      blue = temp - 10;
      blue = 138.5177312231 * log(blue) - 305.0447927307;
      blue = blue.clamp(0, 255);
    }

    return Color.fromRGBO(red.round(), green.round(), blue.round(), 1);
  }

  /// Apply brightness to a color temperature
  static Color kelvinToColorWithBrightness(double kelvin, double brightness) {
    final baseColor = kelvinToColor(kelvin);
    final hsv = HSVColor.fromColor(baseColor);
    return hsv.withValue(brightness.clamp(0.0, 1.0)).toColor();
  }

  /// Predefined temperature values
  static const double warmCandle = 1900;
  static const double warmIncandescent = 2700;
  static const double warmWhite = 3000;
  static const double neutral = 4000;
  static const double coolWhite = 5000;
  static const double coolDaylight = 5500;
  static const double coolBlueSky = 6500;

  /// Get a descriptive name for a temperature value
  static String getTemperatureName(double kelvin) {
    if (kelvin < 2500) return 'Candlelight';
    if (kelvin < 3000) return 'Warm White';
    if (kelvin < 3500) return 'Soft White';
    if (kelvin < 4500) return 'Neutral';
    if (kelvin < 5500) return 'Cool White';
    if (kelvin < 6000) return 'Daylight';
    return 'Cool Daylight';
  }

  /// Common presets for quick selection
  static const List<TemperaturePreset> presets = [
    TemperaturePreset('Warm', 2700, '2700K'),
    TemperaturePreset('Neutral', 4000, '4000K'),
    TemperaturePreset('Cool', 6500, '6500K'),
  ];
}

class TemperaturePreset {
  final String name;
  final double kelvin;
  final String label;

  const TemperaturePreset(this.name, this.kelvin, this.label);
}
