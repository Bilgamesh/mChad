import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/bbtag_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';

class PropertyValueNotifier<T> extends ValueNotifier<T> {
  PropertyValueNotifier(T value) : super(value);

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

ValueNotifier<int> selectedTabNotifier = ValueNotifier(0);
PropertyValueNotifier<ScrollController?> chatScrollNotifier =
    PropertyValueNotifier(null);
PropertyValueNotifier<List<Account>> accountsNotifier = PropertyValueNotifier(
  [],
);
PropertyValueNotifier<Map<Account, List<Message>>> messageMapNotifier =
    PropertyValueNotifier({});
PropertyValueNotifier<Map<Account, List<BBTag>>> bbtagMapNotifier =
    PropertyValueNotifier({});
PropertyValueNotifier<Map<Account, List<Emoticon>>> emoticonMapNotifer =
    PropertyValueNotifier({});
PropertyValueNotifier<Map<Account, OnlineUsersResponse>> onlineUsersMapNotifer =
    PropertyValueNotifier({});
PropertyValueNotifier<Map<Account, int>> editDeleteLimitMapNotifier =
    PropertyValueNotifier({});
PropertyValueNotifier<Map<Account, int>> messageLimitMapNotifier =
    PropertyValueNotifier({});
PropertyValueNotifier<Account?> selectedAccountNotifier = PropertyValueNotifier(
  null,
);
PropertyValueNotifier<Map<Account, DateTime>> refreshTimeMapNotifer =
    PropertyValueNotifier({});
PropertyValueNotifier<Map<Account, VerificationStatus>> refreshStatusNotifier =
    PropertyValueNotifier({});
PropertyValueNotifier<SettingsModel> settingsNotifier = PropertyValueNotifier(
  SettingsModel.getDefault(),
);
ValueNotifier<UpdateStatus> updateNotifier = ValueNotifier(UpdateStatus.none);
