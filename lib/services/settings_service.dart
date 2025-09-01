import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_service.dart';

class SettingsService with ChangeNotifier {
  String _currencySymbol = 'Rs';
  bool _isLoading = false;
  String? _error;

  String get currencySymbol => _currencySymbol;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load settings from Firestore
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Ensure user is authenticated
      if (FirebaseService.currentUserId == null) {
        await FirebaseService.signInAnonymously();
      }

      // Load settings from Firestore
      final doc = await FirebaseService.userSettingsDoc.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _currencySymbol = data['currencySymbol'] ?? 'Rs';
      } else {
        // Create default settings document
        await FirebaseService.userSettingsDoc.set({
          'currencySymbol': _currencySymbol,
        });
      }
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load settings: $e');
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
      await FirebaseService.userSettingsDoc.update({
        'currencySymbol': newSymbol,
      });
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
