import 'dart:async';
import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum TorchMode { off, on, strobe, sos }

class TorchService extends ChangeNotifier {
  bool _isTorchAvailable = false;
  bool _isOn = false;
  TorchMode _mode = TorchMode.off;
  Timer? _strobeTimer;
  Timer? _sosTimer;

  // Strobe frequency (milliseconds)
  int _strobeFrequency = 500;

  // SOS Pattern: ... --- ... (short, short, short, long, long, long, short, short, short)
  // We'll use a simplified version: unit duration.
  // Dot = 1 unit on, 1 unit off
  // Dash = 3 units on, 1 unit off
  // Space between parts = 3 units off (handled by logic)
  // Space between SOS = 7 units off

  // Simplified for easier looping:
  // 1 = ON, 0 = OFF
  final List<int> _sosPattern = [
    1, 0, 1, 0, 1, 0, // ...
    0, 0, // Gap
    1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, // ---
    0, 0, // Gap
    1, 0, 1, 0, 1, 0, // ...
    0, 0, 0, 0, 0, 0, // Long Gap
  ];
  int _sosIndex = 0;
  final int _sosUnitDuration = 200; // ms

  bool get isOn => _isOn;
  TorchMode get mode => _mode;
  int get strobeFrequency => _strobeFrequency;

  TorchService() {
    _checkTorchAvailability();
  }

  Future<void> _checkTorchAvailability() async {
    try {
      _isTorchAvailable = await TorchLight.isTorchAvailable();
    } catch (e) {
      _isTorchAvailable = false;
    }
    notifyListeners();
  }

  Future<void> toggleTorch() async {
    if (!_isTorchAvailable) {
      return;
    }
    vibrate();

    if (_mode == TorchMode.on) {
      await turnOff();
    } else {
      await turnOn();
    }
  }

  Future<void> turnOn() async {
    _stopTimers();
    try {
      if (_isTorchAvailable) {
        await TorchLight.enableTorch();
        _isOn = true;
        _mode = TorchMode.on;
        WakelockPlus.enable();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<void> turnOff() async {
    _stopTimers();
    try {
      if (_isTorchAvailable) {
        await TorchLight.disableTorch();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isOn = false;
    _mode = TorchMode.off;
    WakelockPlus.disable();
    notifyListeners();
  }

  Future<void> setStrobeMode(bool enable) async {
    vibrate();
    if (enable) {
      if (_mode == TorchMode.strobe) {
        return; // Already in strobe
      }
      _stopTimers();
      _mode = TorchMode.strobe;
      WakelockPlus.enable();
      _startStrobe();
    } else {
      await turnOff();
    }
    notifyListeners();
  }

  void updateStrobeFrequency(double val) {
    // val is 0.0 to 1.0. Map to frequency range e.g. 50ms to 1000ms
    // Faster (smaller ms) = Higher val
    // Let's say Slider goes from 0 (slow) to 1 (fast).
    // 0 -> 1000ms, 1 -> 50ms
    int newFreq = (1000 - (val * 950)).round();
    _strobeFrequency = newFreq;

    // Restart timer if running
    if (_mode == TorchMode.strobe) {
      _stopTimers();
      _startStrobe();
    }
    notifyListeners();
  }

  void _startStrobe() {
    bool toggle = true;
    _strobeTimer = Timer.periodic(Duration(milliseconds: _strobeFrequency), (
      timer,
    ) async {
      if (toggle) {
        try {
          await TorchLight.enableTorch();
        } catch (e) {
          debugPrint(e.toString());
        }
      } else {
        try {
          await TorchLight.disableTorch();
        } catch (e) {
          debugPrint(e.toString());
        }
      }
      toggle = !toggle;
    });
  }

  Future<void> setSosMode(bool enable) async {
    vibrate();
    if (enable) {
      if (_mode == TorchMode.sos) {
        return;
      }
      _stopTimers();
      _mode = TorchMode.sos;
      WakelockPlus.enable();
      _startSos();
    } else {
      await turnOff();
    }
    notifyListeners();
  }

  void _startSos() {
    _sosIndex = 0;
    // Base unit is _sosUnitDuration
    // We process the pattern array
    _processSosStep();
  }

  void _processSosStep() {
    if (_mode != TorchMode.sos) {
      return;
    }
    int state = _sosPattern[_sosIndex];
    if (state == 1) {
      TorchLight.enableTorch();
    } else {
      TorchLight.disableTorch();
    }

    _sosIndex = (_sosIndex + 1) % _sosPattern.length;

    _sosTimer = Timer(
      Duration(milliseconds: _sosUnitDuration),
      _processSosStep,
    );
  }

  void _stopTimers() {
    _strobeTimer?.cancel();
    _sosTimer?.cancel();
    _strobeTimer = null;
    _sosTimer = null;
  }

  Future<void> vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}
