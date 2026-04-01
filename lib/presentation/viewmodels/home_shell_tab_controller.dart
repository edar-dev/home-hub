import 'package:flutter/foundation.dart';

/// Indice tab della [HomeShellScreen] (0–3).
class HomeShellTabController extends ChangeNotifier {
  static const int tabOverview = 0;
  static const int tabInventory = 1;
  // Compat: lo step onboarding "locations" punta alla vista inventario.
  static const int tabLocations = tabInventory;
  static const int tabAnalytics = 2;
  static const int tabUtility = 3;

  int _index = 0;

  int get index => _index;

  void setIndex(int i) {
    if (i < 0 || i > tabUtility) return;
    if (_index == i) return;
    _index = i;
    notifyListeners();
  }
}
