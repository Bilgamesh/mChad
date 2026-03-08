import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/data/state/globals.dart' as globals;
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/modal_util.dart';
import 'package:flutter/services.dart';
import 'package:mchad/utils/time_util.dart';
import 'package:mchad/views/widgets/message_edit_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';

class MessageOptionsModal extends StatelessWidget {
  const MessageOptionsModal({
    Key? key,
    this.isSelf = false,
    required this.account,
    required this.message,
    required this.chatboxFocusNode,
    required this.textController,
  }) : super(key: key);
  final bool isSelf;
  final Account account;
  final Message message;
  final FocusNode chatboxFocusNode;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder(
      valueListenable: editDeleteLimitMapNotifier,
      builder: (context, editDeleteLimitMap, child) {
        final editDeleteLimit = editDeleteLimitMap[account] ?? 0;
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.copy),
                    title: Text(l10n.copy),
                    onTap: () => copy(context, message),
                  ),
                  ListTile(
                    leading: Icon(Icons.share),
                    title: Text(l10n.share),
                    onTap: () => share(context, message),
                  ),
                  if (!isSelf)
                    ListTile(
                      leading: Icon(Icons.alternate_email),
                      title: Text(l10n.reply),
                      onTap: () => reply(context, message),
                    ),
                  ListTile(
                    leading: Icon(Icons.format_quote),
                    title: Text(l10n.quote),
                    onTap: () => quote(context, message),
                  ),
                  if (!isSelf)
                    ListTile(
                      leading: Icon(Icons.thumb_up),
                      title: Text(l10n.like),
                      onTap: () => like(context, message),
                    ),
                  if (isSelf &&
                      !TimeUtil.isTimeLimitExceeded(
                        timeMs: int.parse(message.time) * 1000,
                        limitMs: editDeleteLimit,
                      ))
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: Text(l10n.edit),
                      onTap: () => edit(context, message),
                    ),
                  if (isSelf &&
                      !TimeUtil.isTimeLimitExceeded(
                        timeMs: int.parse(message.time) * 1000,
                        limitMs: editDeleteLimit,
                      ))
                    ListTile(
                      iconColor: Colors.red,
                      leading: Icon(Icons.delete),
                      title: Text(
                        l10n.delete,
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => delete(context, message),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void copy(BuildContext context, Message selectedMessage) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    Clipboard.setData(ClipboardData(text: selectedMessage.message.text));
  }

  void share(BuildContext context, Message selectedMessage) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    SharePlus.instance.share(ShareParams(text: selectedMessage.message.text));
  }

  void reply(BuildContext context, Message selectedMessage) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    textController.text =
        '${'${textController.text.trim()} @[url=${account.forumUrl}/memberlist.php?mode=viewprofile&u=${selectedMessage.user.id}][b]${selectedMessage.user.name}[/b][/url]'.trim()} ';
    chatboxFocusNode.requestFocus();
  }

  void quote(BuildContext context, Message selectedMessage) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    textController.text =
        '${textController.text.trim()}${' [quote="${selectedMessage.user.name}" post_id=${selectedMessage.id} time=${selectedMessage.time} user_id=${selectedMessage.user.id}] ${selectedMessage.message.text.replaceAll('\n', ' ')} [/quote]'.trim()} ';
    chatboxFocusNode.requestFocus();
  }

  void like(BuildContext context, Message selectedMessage) {
    final l10n = AppLocalizations.of(context);
    HapticsUtil.vibrate();
    Navigator.pop(context);
    final likeMessage =
        globals.likeMessageMap[account] ?? l10n.defaultLikeMessage;
    textController.text =
        '${'${textController.text.trim()} [i]$likeMessage[/i][quote="${selectedMessage.user.name}" post_id=${selectedMessage.id} time=${selectedMessage.time} user_id=${selectedMessage.user.id}] ${selectedMessage.message.text.replaceAll('\n', ' ')} [/quote]'.trim()} ';
    chatboxFocusNode.requestFocus();
  }

  void edit(BuildContext context, Message selectedMessage) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => MessageEditWidget(selectedMessage: selectedMessage),
    );
  }

  void delete(BuildContext context, Message selectedMessage) {
    final l10n = AppLocalizations.of(context);
    HapticsUtil.vibrate();
    Navigator.pop(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteMessageTitle),
            content: Text(l10n.deleteMessageConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  globals.syncManager.sync.then(
                    (sync) => sync
                        .deleteFromServer(selectedMessage.id)
                        .onError((error, trace) => ModalUtil.showError(error)),
                  );
                },
                child: Text(l10n.confirm, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
