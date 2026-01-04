import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectionService extends ChangeNotifier {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  bool _isEnabled = true;
  bool _isListening = false;
  double _sensitivity = 15.0; // m/s^2 threshold

  // Debounce to prevent multiple triggers
  DateTime _lastShakeTime = DateTime.now();
  static const Duration _shakeCooldown = Duration(milliseconds: 500);

  // Callback for shake detection
  VoidCallback? onShakeDetected;

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isListening => _isListening;
  double get sensitivity => _sensitivity;

  void startListening() {
    if (_isListening) return;

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (!_isEnabled) return;

      final double acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Subtract gravity (~9.8) and check against threshold
      final double netAcceleration = (acceleration - 9.8).abs();

      if (netAcceleration > _sensitivity &&
          DateTime.now().difference(_lastShakeTime) > _shakeCooldown) {
        _lastShakeTime = DateTime.now();
        onShakeDetected?.call();
      }
    });

    _isListening = true;
    notifyListeners();
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isListening = false;
    notifyListeners();
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled && !_isListening) {
      startListening();
    } else if (!enabled && _isListening) {
      stopListening();
    }
    notifyListeners();
  }

  void setSensitivity(double value) {
    _sensitivity = value.clamp(5.0, 30.0);
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
