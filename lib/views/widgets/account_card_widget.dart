import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/time_util.dart';
import 'package:mchad/utils/value_listenables_builder.dart';
import 'package:mchad/views/widgets/avatar_widget.dart';
import 'package:mchad/views/widgets/online_users_modal.dart';
import 'package:mchad/views/widgets/verification_icon_widget.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';

class AccountCardWidget extends StatefulWidget {
  const AccountCardWidget({
    Key? key,
    required this.account,
    required this.onOpen,
    required this.onSelect,
    required this.onLogout,
    required this.isSelected,
  }) : super(key: key);
  final Account account;
  final Function()? onOpen;
  final Function()? onSelect;
  final Function() onLogout;
  final bool isSelected;

  @override
  State<AccountCardWidget> createState() => _AccountCardWidgetState();
}

class _AccountCardWidgetState extends State<AccountCardWidget> {
  Timer? timer;
  String? timeRelative;
  String? lastCookies;
  @override
  void initState() {
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      updateTime();
    });
    refreshTimeMapNotifer.addListener(updateTime);
    super.initState();
  }

  void updateTime() async {
    final timeRelativeNew = await TimeUtil.convertToAgo(
      refreshTimeMapNotifer.value[widget.account] ?? DateTime.now(),
    );
    setState(() {
      timeRelative = timeRelativeNew;
    });
  }

  String getTimeRelative(BuildContext context) {
    return TimeUtil.convertToAgoSync(
      refreshTimeMapNotifer.value[widget.account] ?? DateTime.now(),
      context,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    refreshTimeMapNotifer.removeListener(updateTime);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenablesBuilder(
    listenables: [
      settingsNotifier,
      onlineUsersMapNotifer,
      refreshStatusNotifier,
      messageMapNotifier,
    ],
    builder: (context, values, child) {
      final settings = values[0] as SettingsModel;
      final onlineUsersMap = values[1] as Map<Account, OnlineUsersResponse>;
      final onlineUsers = onlineUsersMap[widget.account];
      final refreshStatusMap = values[2] as Map<Account, VerificationStatus>;
      final refreshStatus =
          refreshStatusMap[widget.account] ?? VerificationStatus.none;
      final messageMap = values[3] as Map<Account, List<Message>>;
      final messages = messageMap[widget.account] ?? [];
      final unreadMessages = messages.where((m) => !(m.isRead ?? false));
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: ListTile(
          selected: widget.isSelected,
          onTap: widget.onSelect,
          leading: AvatarWidget(
            avatarSrc: widget.account.avatarUrl,
            account: widget.account,
          ),
          titleAlignment: ListTileTitleAlignment.titleHeight,
          onLongPress: () => showOnlineUsersModal(context, onlineUsers),
          title: Row(
            children: [
              Text(
                widget.account.userName,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Expanded(child: SizedBox.shrink()),
              VerificationIconWidget(status: refreshStatus),
            ],
          ),
          selectedTileColor: settings.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          minTileHeight: 200.0,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: switch (widget.isSelected) {
                  true => Text(
                    '@${widget.account.forumName} - ${AppLocalizations.of(context).currentlySelected}',
                  ),
                  false => Text('@${widget.account.forumName}'),
                },
              ),
              FittedBox(
                child: Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context).numberOfUsers}: ${onlineUsers?.totalCount ?? 0}',
                    ),
                    IconButton(
                      onPressed: () {
                        HapticsUtil.vibrate();
                        showOnlineUsersModal(context, onlineUsers);
                      },
                      icon: Icon(Icons.info_outline),
                    ),
                  ],
                ),
              ),
              if (!widget.isSelected && unreadMessages.isNotEmpty)
                SizedBox(
                  height: 30,
                  child: Text(
                    '${AppLocalizations.of(context).unreadMessages}: ${unreadMessages.length}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              Row(
                children: [
                  SizedBox(
                    height: 38,
                    child: switch (refreshStatus) {
                      VerificationStatus.loading => Text(
                        AppLocalizations.of(context).chatRefreshing,
                      ),
                      VerificationStatus.error => Text(
                        '${AppLocalizations.of(context).chatRefreshError} ${timeRelative ?? getTimeRelative(context)}',
                        style: TextStyle(color: Colors.red),
                      ),
                      _ => Text(
                        '${AppLocalizations.of(context).chatRefreshed} ${timeRelative ?? getTimeRelative(context)}',
                      ),
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(child: SizedBox.shrink()),
                  OutlinedButton(
                    onPressed: widget.onOpen,
                    child: Row(
                      children: [
                        Icon(Icons.menu_open),
                        Text(' ${AppLocalizations.of(context).open} '),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.0),
                  OutlinedButton(
                    onPressed: widget.onLogout,
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        Text(AppLocalizations.of(context).logout),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  void showOnlineUsersModal(
    BuildContext context,
    OnlineUsersResponse? onlineUsers,
  ) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder:
          (context) => SafeArea(
            child: OnlineUsersModal(
              onlineUsers: onlineUsers?.users ?? [],
              onlineBots: onlineUsers?.bots ?? [],
              hiddenCount: onlineUsers?.hiddenCount ?? 0,
            ),
          ),
    );
  }
}
