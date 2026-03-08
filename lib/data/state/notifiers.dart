import 'package:flutter/material.dart';
import 'package:mchad/utils/notifier_util.dart';
import 'package:mchad/config/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/bbtag_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

final selectedTabNotifier = ValueNotifier(0);
final chatScrollOffsetNotifier = ValueNotifier(0.0);
final accountsNotifier = PropertyValueNotifier(<Account>[]);
final messageMapNotifier = PropertyValueNotifier(<Account, List<Message>>{});
final bbtagMapNotifier = PropertyValueNotifier(<Account, List<BBTag>>{});
final emoticonMapNotifer = PropertyValueNotifier(<Account, List<Emoticon>>{});
final onlineUsersMapNotifer = PropertyValueNotifier(
  <Account, OnlineUsersResponse>{},
);
final editDeleteLimitMapNotifier = PropertyValueNotifier(<Account, int>{});
final messageLimitMapNotifier = PropertyValueNotifier(<Account, int>{});
final selectedAccountNotifier = PropertyValueNotifier<Account?>(null);
final refreshTimeMapNotifer = PropertyValueNotifier(<Account, DateTime>{});
final refreshStatusNotifier = PropertyValueNotifier(
  <Account, VerificationStatus>{},
);
final settingsNotifier = PropertyValueNotifier(SettingsModel.defaultSettings);
final updateNotifier = ValueNotifier(UpdateStatus.none);
final packageInfoNotifier = ValueNotifier<PackageInfo?>(null);
final timeRelativeMapNotifier = PropertyValueNotifier(<Account, String>{});