import 'package:mchad/data/models/bbtag_model.dart';
import 'package:mchad/data/models/message_model.dart';

class MchatChatModel {
  MchatChatModel({
    this.creationTime,
    this.formToken,
    this.cookie,
    this.messages,
    this.bbtags,
    this.editDeleteLimit,
    this.messageLimit,
  });
  final String? creationTime, formToken, cookie;
  final int? editDeleteLimit, messageLimit;
  final List<Message>? messages;
  final List<BBTag>? bbtags;
}

class MchatRefreshResponse {
  MchatRefreshResponse({this.cookie, this.add, this.edit, this.del, this.log});
  final String? cookie, log;
  final List<int>? del;
  final List<Message>? add, edit;
}
