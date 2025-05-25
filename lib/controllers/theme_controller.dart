import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static ThemeController get instance => Get.find();

  // Normal variable instead of Rx
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    // Load saved theme preference
    _loadThemeFromStorage();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    Get.changeThemeMode(themeMode);
    _saveThemeToStorage();
    update(); // Update UI
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    Get.changeThemeMode(themeMode);
    _saveThemeToStorage();
    update(); // Update UI
  }

  void _loadThemeFromStorage() {
    // For now, we'll start with light theme
    // You can implement SharedPreferences here to persist theme choice
    _isDarkMode = false;
    update(); // Update UI
  }

  void _saveThemeToStorage() {
    // You can implement SharedPreferences here to persist theme choice
    // For now, we'll just use the in-memory value
  }
}
