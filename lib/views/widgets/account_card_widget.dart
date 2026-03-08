import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mchad/config/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/time_util.dart';
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
    required this.settings,
    required this.onlineUsersMap,
    required this.refreshStatusMap,
    required this.messageMap,
  }) : super(key: key);
  final Account account;
  final Function()? onOpen;
  final Function()? onSelect;
  final Function() onLogout;
  final bool isSelected;
  final SettingsModel settings;
  final Map<Account, OnlineUsersResponse> onlineUsersMap;
  final Map<Account, VerificationStatus> refreshStatusMap;
  final Map<Account, List<Message>> messageMap;

  @override
  State<AccountCardWidget> createState() => _AccountCardWidgetState();
}

class _AccountCardWidgetState extends State<AccountCardWidget> {
  Timer? timer;
  String? timeRelative;
  String? lastCookies;
  @override
  void initState() {
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      updateTime();
    });
    refreshTimeMapNotifer.addListener(updateTime);
    super.initState();
  }

  void updateTime() {
    final timeRelativeNew = TimeUtil.convertToAgoSync(
      refreshTimeMapNotifer.value[widget.account] ?? DateTime.now(),
      context,
    );
    if (timeRelative != timeRelativeNew)
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
  Widget build(BuildContext context) {
    final onlineUsers = widget.onlineUsersMap[widget.account];
    final refreshStatus =
        widget.refreshStatusMap[widget.account] ?? VerificationStatus.none;
    final messages = widget.messageMap[widget.account] ?? [];
    final unreadMessagesCount =
        messages.where((m) => !(m.isRead ?? false)).length;
    final l10n = AppLocalizations.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
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
        selectedTileColor: widget.settings.colorScheme.surfaceContainerHigh,
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
                  '@${widget.account.forumName} - ${l10n.currentlySelected}',
                ),
                false => Text('@${widget.account.forumName}'),
              },
            ),
            FittedBox(
              child: Row(
                children: [
                  Text(
                    '${l10n.numberOfUsers}: ${onlineUsers?.totalCount ?? 0}',
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
            if (!widget.isSelected && unreadMessagesCount > 0)
              SizedBox(
                height: 30,
                child: Text(
                  '${l10n.unreadMessages}: $unreadMessagesCount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Row(
              children: [
                SizedBox(
                  height: 38,
                  child: switch (refreshStatus) {
                    VerificationStatus.loading => Text(l10n.chatRefreshing),
                    VerificationStatus.error => Text(
                      '${l10n.chatRefreshError} ${timeRelative ?? getTimeRelative(context)}',
                      style: TextStyle(color: Colors.red),
                    ),
                    _ => Text(
                      '${l10n.chatRefreshed} ${timeRelative ?? getTimeRelative(context)}',
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
                    children: [Icon(Icons.menu_open), Text(' ${l10n.open} ')],
                  ),
                ),
                SizedBox(width: 10.0),
                OutlinedButton(
                  onPressed: widget.onLogout,
                  child: Row(children: [Icon(Icons.logout), Text(l10n.logout)]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
