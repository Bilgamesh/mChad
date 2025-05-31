import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/services/notifications/notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  SettingsStore({required this.prefs}) : key = 'app_theme';
  final String key;
  SharedPreferences prefs;

  static Future<SettingsStore> getInstance() async {
    var prefs = await SharedPreferences.getInstance();
    return SettingsStore(prefs: prefs);
  }

  void setSettings(SettingsModel settings) {
    prefs.setString(key, settings.toString());
  }

  Future<SettingsModel> getSettings() async {
    var strinfigiedTheme = prefs.getString(key);
    if (strinfigiedTheme == null) return SettingsModel.getDefault();
    var settings = SettingsModel.fromString(strinfigiedTheme);
    if (settings.notifications) {
      settings.notifications = await NotificationsService.notificationsEnabled;
    }
    return settings;
  }
}
