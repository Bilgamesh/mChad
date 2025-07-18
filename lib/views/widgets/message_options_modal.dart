import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/data/globals.dart' as globals;
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/modal_util.dart';
import 'package:flutter/services.dart';
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
    return Wrap(
      children: [
        ListTile(
          leading: Icon(Icons.copy),
          title: Text(AppLocalizations.of(context)!.copy),
          onTap: () => copy(context, message),
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text(AppLocalizations.of(context)!.share),
          onTap: () => share(context, message),
        ),
        isSelf
            ? SizedBox.shrink()
            : ListTile(
              leading: Icon(Icons.alternate_email),
              title: Text(AppLocalizations.of(context)!.reply),
              onTap: () => reply(context, message),
            ),
        ListTile(
          leading: Icon(Icons.format_quote),
          title: Text(AppLocalizations.of(context)!.quote),
          onTap: () => quote(context, message),
        ),
        isSelf
            ? SizedBox.shrink()
            : ListTile(
              leading: Icon(Icons.thumb_up),
              title: Text(AppLocalizations.of(context)!.like),
              onTap: () => like(context, message),
            ),
        ValueListenableBuilder(
          valueListenable: editDeleteLimitMapNotifier,
          builder:
              (context, editDeleteLimitMap, child) =>
                  isSelf &&
                          DateTime.now().millisecondsSinceEpoch -
                                  int.parse(message.time) * 1000 <
                              (editDeleteLimitMap[account] ?? 0)
                      ? ListTile(
                        leading: Icon(Icons.edit),
                        title: Text(AppLocalizations.of(context)!.edit),
                        onTap: () => edit(context, message),
                      )
                      : SizedBox.shrink(),
        ),
        ValueListenableBuilder(
          valueListenable: editDeleteLimitMapNotifier,
          builder:
              (context, editDeleteLimitMap, child) =>
                  isSelf &&
                          DateTime.now().millisecondsSinceEpoch -
                                  int.parse(message.time) * 1000 <
                              (editDeleteLimitMap[account] ?? 0)
                      ? ListTile(
                        iconColor: Colors.red,
                        leading: Icon(Icons.delete),
                        title: Text(
                          AppLocalizations.of(context)!.delete,
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () => delete(context, message),
                      )
                      : SizedBox.shrink(),
        ),
      ],
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

  void like(
    BuildContext context,
    Message selectedMessage,
  ) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    var likeMessage =
        globals.likeMessageMap[account] ??
        AppLocalizations.of(context)!.defaultLikeMessage;
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

  void delete(
    BuildContext context,
    Message selectedMessage,
  ) {
    HapticsUtil.vibrate();
    Navigator.pop(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteMessageTitle),
            content: Text(
              AppLocalizations.of(context)!.deleteMessageConfirmation,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
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
                child: Text(
                  AppLocalizations.of(context)!.confirm,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
