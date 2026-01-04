import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _shakeEnabledKey = 'shake_enabled';
  static const String _shakeSensitivityKey = 'shake_sensitivity';
  static const String _screenBrightnessKey = 'screen_brightness';
  static const String _colorTemperatureKey = 'color_temperature';

  SharedPreferences? _prefs;

  // Shake settings
  bool _shakeEnabled = true;
  double _shakeSensitivity = 15.0; // m/s^2 threshold

  // Screen light settings
  double _screenBrightness = 1.0; // 0.0 to 1.0
  double _colorTemperature = 6500; // Kelvin (2700 warm - 6500 cool)

  // Getters
  bool get shakeEnabled => _shakeEnabled;
  double get shakeSensitivity => _shakeSensitivity;
  double get screenBrightness => _screenBrightness;
  double get colorTemperature => _colorTemperature;

  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    _shakeEnabled = _prefs?.getBool(_shakeEnabledKey) ?? true;
    _shakeSensitivity = _prefs?.getDouble(_shakeSensitivityKey) ?? 15.0;
    _screenBrightness = _prefs?.getDouble(_screenBrightnessKey) ?? 1.0;
    _colorTemperature = _prefs?.getDouble(_colorTemperatureKey) ?? 6500;

    notifyListeners();
  }

  Future<void> setShakeEnabled(bool value) async {
    _shakeEnabled = value;
    await _prefs?.setBool(_shakeEnabledKey, value);
    notifyListeners();
  }

  Future<void> setShakeSensitivity(double value) async {
    _shakeSensitivity = value.clamp(5.0, 30.0);
    await _prefs?.setDouble(_shakeSensitivityKey, _shakeSensitivity);
    notifyListeners();
  }

  Future<void> setScreenBrightness(double value) async {
    _screenBrightness = value.clamp(0.1, 1.0);
    await _prefs?.setDouble(_screenBrightnessKey, _screenBrightness);
    notifyListeners();
  }

  Future<void> setColorTemperature(double value) async {
    _colorTemperature = value.clamp(2700, 6500);
    await _prefs?.setDouble(_colorTemperatureKey, _colorTemperature);
    notifyListeners();
  }
}
