import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassService extends ChangeNotifier {
  StreamSubscription<CompassEvent>? _compassSubscription;

  double? _heading; // 0-360 degrees
  double? _accuracy;
  bool _isAvailable = false;
  bool _isListening = false;

  // Getters
  double? get heading => _heading;
  double? get accuracy => _accuracy;
  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;

  String get cardinalDirection => _getCardinalDirection(_heading);

  Future<void> initialize() async {
    try {
      _isAvailable = FlutterCompass.events != null;
    } catch (e) {
      _isAvailable = false;
    }
    notifyListeners();
  }

  void startListening() {
    if (_isListening || !_isAvailable) return;

    _compassSubscription = FlutterCompass.events?.listen((event) {
      _heading = event.heading;
      _accuracy = event.accuracy;
      notifyListeners();
    });

    _isListening = true;
    notifyListeners();
  }

  void stopListening() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _isListening = false;
    notifyListeners();
  }

  String _getCardinalDirection(double? heading) {
    if (heading == null) return '--';

    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((heading + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  String getFullCardinalDirection(double? heading) {
    if (heading == null) return 'Unknown';

    const directions = [
      'North',
      'Northeast',
      'East',
      'Southeast',
      'South',
      'Southwest',
      'West',
      'Northwest',
    ];
    final index = ((heading + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
