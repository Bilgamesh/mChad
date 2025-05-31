import 'dart:async';

import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/utils/document_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  User({required this.id, required this.name});
  final String id, name;
}

class Avatar {
  Avatar({required this.src, required this.width});
  final String src;
  final int width;
}

class InnerMessage {
  InnerMessage({required this.text, required this.html, required this.baseUrl})
    : shortHtml = DocumentUtil.fixMessageLinks(
        baseUrl,
        DocumentUtil.removeInnerBlockquotes(html),
      );
  final String text, html, shortHtml, baseUrl;
}

class Message {
  Message({
    required this.id,
    required this.time,
    required this.user,
    required this.message,
    required this.avatar,
    required this.likeMessage,
    required this.logId,
    bool isRead = false,
  }) {
    Timer(const Duration(milliseconds: 500), () {
      isNew = false;
    });
  }
  final int id;
  final String time;
  final String? likeMessage, logId;
  final User user;
  final InnerMessage message;
  final Avatar avatar;
  bool? isRead;
  bool notificationSent = false;
  bool isNew = true;
  bool isDeleting = false;

  @override
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  int get hashCode => id;

  void read() {
    isRead = true;
  }

  void notify() {
    notificationSent = true;
  }

  void delete() {
    isDeleting = true;
  }

  Future<void> saveAsLatest(Account account) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${account.hashCode}_latestMessageId', id);
  }

  static Future<int> getLatestId(Account account) async {
    var prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt('${account.hashCode}_latestMessageId');
    return id ?? 0;
  }
}
