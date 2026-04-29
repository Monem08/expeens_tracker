import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-configurable preferences persisted via [SharedPreferences].
///
/// Kept small on purpose: display name and currency symbol are the only
/// two knobs exposed from Profile. Anything more involved (theme, locale,
/// number formatting) should grow from here rather than via a new store.
class SettingsStore extends ChangeNotifier {
  SettingsStore(this._prefs);

  static const _kDisplayName = 'settings.displayName';
  static const _kCurrencySymbol = 'settings.currencySymbol';

  final SharedPreferences _prefs;

  String get displayName => _prefs.getString(_kDisplayName) ?? 'You';

  Future<void> setDisplayName(String value) async {
    await _prefs.setString(_kDisplayName, value);
    notifyListeners();
  }

  String get currencySymbol => _prefs.getString(_kCurrencySymbol) ?? '\$';

  Future<void> setCurrencySymbol(String value) async {
    await _prefs.setString(_kCurrencySymbol, value);
    notifyListeners();
  }
}
