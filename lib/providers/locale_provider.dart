import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? lang = prefs.getString('language_code');
    if (lang != null) {
      _locale = Locale(lang);
      notifyListeners();
    }
  }

  void setLocale(Locale loc) async {
    if (!['en', 'vi'].contains(loc.languageCode)) return;

    _locale = loc;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', loc.languageCode);
  }
}
