import 'package:flutter/material.dart';
import 'package:media_house/data/themes/custom_theme.dart';
import 'package:media_house/app/core/storage/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _selectedTheme;

  ThemeProvider({bool isDark = false}) {
    _selectedTheme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  ThemeData get getTheme => _selectedTheme;

  bool get isDark => _selectedTheme == AppTheme.darkTheme;

  Future<void> toggleTheme() async {
    _selectedTheme = isDark ? AppTheme.lightTheme : AppTheme.darkTheme;
    await StorageService.instance.preferences.setDarkMode(isDark);
    notifyListeners();
  }
}
