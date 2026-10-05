import 'package:flutter/material.dart';

/// Provider managing system-wide UI scale / zoom level (50% to 225% in 25% increments).
class SystemZoomProvider extends ChangeNotifier {
  double _zoomLevel = 1.0;

  double get zoomLevel => _zoomLevel;

  void zoomIn() {
    if (_zoomLevel < 2.25) {
      _zoomLevel = double.parse((_zoomLevel + 0.25).toStringAsFixed(2));
      notifyListeners();
    }
  }

  void zoomOut() {
    if (_zoomLevel > 0.50) {
      _zoomLevel = double.parse((_zoomLevel - 0.25).toStringAsFixed(2));
      notifyListeners();
    }
  }

  void setZoom(double value) {
    _zoomLevel = value.clamp(0.50, 2.25);
    notifyListeners();
  }

  void resetZoom() {
    _zoomLevel = 1.0;
    notifyListeners();
  }
}
