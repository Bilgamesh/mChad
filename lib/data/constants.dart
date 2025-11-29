import 'package:flutter/material.dart';

enum VerificationStatus { none, loading, error, success }

enum UpdateStatus { none, available, inProgress }

class KTimerConfig {
  static const timerIntervalSeconds = 5;
  static const updateCheckIntervalSeconds = 300;
}

class KCloudflareConfig {
  static const cloudflareTimeoutSeconds = 10;
}

class KImageConfig {
  static const imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.tiff',
    '.webp',
    '.svg',
    '.heif',
    '.ico',
  ];
}

class KTextStyle {
  static const TextStyle settingsLabelText = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );
}

class KNavigationBarStyle {
  static const navigationBarHeight = 80.0;
}

class KAppTheme {
  static const List<Color> appColors = [
    Color(0xFF2196F3),
    Color(0xFF03A9F4),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF008080),
    Color(0xFF3F51B5),
    Color(0xFF673AB7),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFFF44336),
    Color(0xFFFF5722),
    Color(0xFFFF9800),
    Color(0xFFFFC107),
    Color(0xFFFFEB3B),
    Color(0xFFCDDC39),
    Color(0xFF8BC34A),
    Color(0xFF4CAF50),
    Color(0xFF795548),
    Color(0xFF9E9E9E),
    Color(0xFF607D8B),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFFE6E6FA),
    Color(0xFFFF7F50),
  ];
}

class KUpdateConfig {
  static const endpoint =
      'https://api.github.com/repos/Bilgamesh/mChad/releases';
}

class KRepositoryInfo {
  static const licenseUrl =
      "https://github.com/Bilgamesh/mChad/blob/master/LICENSE";
  static const repoUrl = "https://github.com/Bilgamesh/mChad";
  static const issueTrackerUrl = "https://github.com/Bilgamesh/mChad/issues";}

class KNotificationsConfig {
  static const maxNotificationMessages = 5;
  static const channelId = 'mChad-notifications-channel';
  static const channelName = 'mChad-notifications-channel';
  static const icon = '@drawable/notif';
}
