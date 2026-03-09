import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/storage_helper.dart';

class ThemeController extends GetxController {
  final _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final storedMode = StorageHelper.getString('theme_mode') ?? 'system';
    _themeMode.value = _getModeFromString(storedMode);
    Get.changeThemeMode(_themeMode.value);
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    StorageHelper.saveString('theme_mode', mode.name);
    Get.changeThemeMode(mode);
  }

  ThemeMode _getModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  IconData getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}
