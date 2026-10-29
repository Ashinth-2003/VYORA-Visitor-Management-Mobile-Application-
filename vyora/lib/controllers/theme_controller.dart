import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._(this._prefs, this._isDark);

  final SharedPreferences _prefs;
  bool _isDark;

  bool get isDark => _isDark;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;

  static Future<ThemeController> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeController._(prefs, prefs.getBool('isDark') ?? true);
  }

  void toggle() {
    _isDark = !_isDark;
    _prefs.setBool('isDark', _isDark);
    notifyListeners();
  }
}
