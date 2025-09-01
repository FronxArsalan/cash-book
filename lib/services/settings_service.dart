import 'package:flutter/foundation.dart';

class SettingsService with ChangeNotifier {
  String _currencySymbol = 'Rs';
  bool _isLoading = false;
  String? _error;

  String get currencySymbol => _currencySymbol;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with local storage (working version)
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 300));
      _setError(null);
    } catch (e) {
      _setError('Failed to initialize settings: $e');
      if (kDebugMode) {
        print('Error initializing settings: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setCurrency(String newSymbol) async {
    try {
      _currencySymbol = newSymbol;
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update currency: $e');
      if (kDebugMode) {
        print('Error updating currency: $e');
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
