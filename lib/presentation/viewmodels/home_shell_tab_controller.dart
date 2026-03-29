import 'package:flutter/foundation.dart';

/// Indice tab della [HomeShellScreen] (0–5).
class HomeShellTabController extends ChangeNotifier {
  static const int tabInventory = 0;
  static const int tabLocations = 1;
  static const int tabSummary = 2;
  static const int tabAnalytics = 3;
  static const int tabShopping = 4;
  static const int tabNotifications = 5;

  int _index = 0;

  int get index => _index;

  void setIndex(int i) {
    if (i < 0 || i > tabNotifications) return;
    if (_index == i) return;
    _index = i;
    notifyListeners();
  }
}
