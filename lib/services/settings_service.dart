import 'package:flutter/foundation.dart';

class SettingsService with ChangeNotifier {
  String _currencySymbol = 'Rs';

  String get currencySymbol => _currencySymbol;

  void setCurrency(String newSymbol) {
    _currencySymbol = newSymbol;
    notifyListeners();
  }
}
