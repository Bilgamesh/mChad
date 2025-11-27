import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/jobs/mchat/mchat_sync_manager.dart';
import 'package:mchad/jobs/mchat/mchat_sync.dart';
import 'package:mchad/jobs/update_check.dart';

MchatSyncManager syncManager = MchatSyncManager();
UpdateCheck updateCheck = UpdateCheck(endpoint: KUpdateConfig.endpoint);
List<MchatSync> syncs = [];
bool appInitialized = false;
Map<Account, String> logIdMap = {};
Map<Account, String> chatBoxValueMap = {};
Map<Account, TextSelection?> textSelectionMap = {};
Map<Account, String> likeMessageMap = {};
int focusLocksCount = 0;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool background = false;
ScrollController? chatScrollController;
