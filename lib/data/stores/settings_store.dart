import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/services/notifications/notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  SettingsStore({required this.prefs}) : key = 'app_theme';
  final String key;
  SharedPreferences prefs;

  static Future<SettingsStore> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsStore(prefs: prefs);
  }

  void setSettings(SettingsModel settings) {
    prefs.setString(key, settings.toString());
  }

  Future<SettingsModel> getSettings() async {
    final strinfigiedSettings = prefs.getString(key);
    if (strinfigiedSettings == null) return SettingsModel.getDefault();
    final settings = SettingsModel.fromString(strinfigiedSettings);
    if (settings.notifications) {
      settings.notifications = await NotificationsService.notificationsEnabled;
    }
    return settings;
  }
}
