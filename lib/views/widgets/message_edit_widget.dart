import 'package:flutter/material.dart';
import 'package:mchad/data/globals.dart' as globals;
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/modal_util.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';

class MessageEditWidget extends StatefulWidget {
  const MessageEditWidget({Key? key, required this.selectedMessage})
    : super(key: key);
  final Message selectedMessage;

  @override
  _MessageEditWidgetState createState() => _MessageEditWidgetState();
}

class _MessageEditWidgetState extends State<MessageEditWidget> {
  final editController = TextEditingController();
  var validated = false;

  @override
  void initState() {
    super.initState();
    editController.text = widget.selectedMessage.message.text;
    editController.addListener(validate);
  }

  @override
  void dispose() {
    super.dispose();
    editController.removeListener(validate);
    editController.dispose();
  }

  void validate() {
    if (editController.text.trim() != widget.selectedMessage.message.text) {
      setState(() {
        validated = true;
      });
    } else {
      setState(() {
        validated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).editTitle),
      content: SizedBox(
        child: TextField(
          controller: editController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 4,
          decoration: InputDecoration(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticsUtil.vibrate();
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: switch (validated) {
            false => null,
            true => () {
              HapticsUtil.vibrate();
              Navigator.pop(context);
              if (widget.selectedMessage.message.text.trim() ==
                  editController.text.trim()) {
                return;
              }
              globals.syncManager.sync.then(
                (sync) => sync
                    .editOnServer(
                      widget.selectedMessage.id,
                      editController.text,
                    )
                    .onError((error, trace) => ModalUtil.showError(error)),
              );
            },
          },
          child: Text(AppLocalizations.of(context).confirm),
        ),
      ],
    );
  }
}
