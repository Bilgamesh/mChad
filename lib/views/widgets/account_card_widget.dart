import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/crypto_util.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/time_util.dart';
import 'package:mchad/views/widgets/online_users_modal.dart';
import 'package:mchad/views/widgets/verification_icon_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    var timeRelativeNew = await TimeUtil.convertToAgo(
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
  Widget build(BuildContext context) {
    var headers = {
      'x-requested-with': 'XMLHttpRequest',
      'cookie': widget.account.cachedCookies ?? '',
      'user-agent': widget.account.userAgent ?? '',
    };
    return ValueListenableBuilder(
      valueListenable: settingsNotifier,
      builder:
          (context, settings, child) => ValueListenableBuilder(
            valueListenable: onlineUsersMapNotifer,
            builder:
                (context, onlineUsersMap, child) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: ListTile(
                    selected: widget.isSelected,
                    onTap: widget.onSelect,
                    leading: CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.transparent,
                      foregroundImage:
                          widget.account.avatarUrl != null
                              ? CachedNetworkImageProvider(
                                widget.account.avatarUrl!,
                                headers:
                                    widget.account.avatarUrl!.startsWith(
                                          widget.account.forumUrl,
                                        )
                                        ? headers
                                        : {},
                                cacheKey: CryptoUtil.generateMd5(
                                  '$headers${widget.account.avatarUrl!}',
                                ),
                              )
                              : AssetImage('assets/images/no_avatar.gif'),
                    ),
                    titleAlignment: ListTileTitleAlignment.titleHeight,
                    onLongPress:
                        () => showOnlineUsersModal(context, onlineUsersMap),
                    title: Row(
                      children: [
                        Text(
                          widget.account.userName,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Expanded(child: SizedBox.shrink()),
                        ValueListenableBuilder(
                          valueListenable: refreshStatusNotifier,
                          builder:
                              (context, refreshStatusMap, child) =>
                                  VerificationIconWidget(
                                    status:
                                        refreshStatusMap[widget.account] ??
                                        VerificationStatus.none,
                                  ),
                        ),
                      ],
                    ),
                    selectedTileColor:
                        settings.colorScheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    minTileHeight: 200.0,
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            widget.isSelected
                                ? '@${widget.account.forumName} - ${AppLocalizations.of(context).currentlySelected}'
                                : '@${widget.account.forumName}',
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              Text(
                                '${AppLocalizations.of(context).numberOfUsers}: ${onlineUsersMap[widget.account]?.totalCount ?? 0}',
                              ),
                              IconButton(
                                onPressed: () {
                                  HapticsUtil.vibrate();
                                  showOnlineUsersModal(context, onlineUsersMap);
                                },
                                icon: Icon(Icons.info_outline),
                              ),
                            ],
                          ),
                        ),
                        widget.isSelected
                            ? SizedBox.shrink()
                            : ValueListenableBuilder(
                              valueListenable: messageMapNotifier,
                              builder: (context, messageMap, child) {
                                var unreadMessages = messageMap[widget.account]!
                                    .where((m) => !(m.isRead ?? false));
                                if (unreadMessages.isEmpty) {
                                  return SizedBox.shrink();
                                }
                                return SizedBox(
                                  height: 30,
                                  child: Text(
                                    '${AppLocalizations.of(context).unreadMessages}: ${unreadMessages.length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                        Row(
                          children: [
                            ValueListenableBuilder(
                              valueListenable: refreshStatusNotifier,
                              builder:
                                  (
                                    context,
                                    refreshStatusMap,
                                    child,
                                  ) => SizedBox(
                                    height: 38,
                                    child: Text(
                                      refreshStatusMap[widget.account] ==
                                              VerificationStatus.loading
                                          ? AppLocalizations.of(
                                            context,
                                          ).chatRefreshing
                                          : (refreshStatusMap[widget.account] ==
                                                  VerificationStatus.error
                                              ? '${AppLocalizations.of(context).chatRefreshError} ${timeRelative ?? getTimeRelative(context)}'
                                              : '${AppLocalizations.of(context).chatRefreshed} ${timeRelative ?? getTimeRelative(context)}'),
                                      style:
                                          refreshStatusMap[widget.account] ==
                                                  VerificationStatus.error
                                              ? TextStyle(color: Colors.red)
                                              : TextStyle(),
                                    ),
                                  ),
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
                                  Text(
                                    ' ${AppLocalizations.of(context).open} ',
                                  ),
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
                ),
          ),
    );
  }

  void showOnlineUsersModal(
    BuildContext context,
    Map<Account, OnlineUsersResponse> onlineUsersMap,
  ) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder:
          (context) => SafeArea(
            child: OnlineUsersModal(
              onlineUsers: onlineUsersMap[widget.account]?.users ?? [],
              onlineBots: onlineUsersMap[widget.account]?.bots ?? [],
              hiddenCount: onlineUsersMap[widget.account]?.hiddenCount ?? 0,
            ),
          ),
    );
  }
}
