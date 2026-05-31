import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'app_theme';
  static const String _langKey = 'app_language';

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Default Light
  }

  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'en'; // Default English
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }
}