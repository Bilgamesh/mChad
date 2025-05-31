import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/mchat_chat_model.dart';
import 'package:mchad/data/models/message_model.dart';
import 'package:mchad/services/cloudflare/cloudflare_service.dart';
import 'package:mchad/utils/document_util.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:mchad/utils/url_util.dart';

var logger = LoggingUtil(module: 'mchat_chat_service');

class MchatChatService {
  MchatChatService({required this.account});
  final Account account;

  Future<MchatChatModel> fetchMainPage() async {
    try {
      var targetUrl = '${account.forumUrl}/app.php/mchat';
      final Map<String, String> headers = {
        'accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'cookie': await account.getCookies(),
      };
      if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
      var streamedResponse = await (Client().send(
        Request('GET', Uri.parse(targetUrl))..headers.addAll(headers),
      ));
      var response = await Response.fromStream(streamedResponse);
      if (DocumentUtil.hasSessionCookie(response.headers)) {
        var cookies = DocumentUtil.extractCookie(response.headers)!;
        await account.updateCookies(cookies);
      }
      if (DocumentUtil.isCloudflare(response.body, account.forumUrl)) {
        await updateCloudflare();
        return await fetchMainPage();
      }
      var doc = parse(response.body);
      var bbtags = DocumentUtil.extractBBTags(doc);
      var editDeleteLimit = DocumentUtil.extractEditDeleteLimit(doc);
      var messageLimit = DocumentUtil.extractMessageLimit(doc);
      var messages = parseMessages(response.body, account.forumUrl);
      var formToken = DocumentUtil.findInputData(doc, 'form_token', 'value');
      var creationTime = DocumentUtil.findInputData(
        doc,
        'creation_time',
        'value',
      );
      if (messages.isEmpty) {
        logger.info('No posts found in main page HTML');
      }
      return MchatChatModel(
        bbtags: bbtags,
        creationTime: creationTime,
        editDeleteLimit: editDeleteLimit,
        formToken: formToken,
        messageLimit: messageLimit,
        messages: messages,
      );
    } catch (e, trace) {
      logger.error(e.toString());
      logger.error(trace.toString());
      throw 'Could not fetch main page from server';
    }
  }

  Future<MchatRefreshResponse> refresh(int last, String log) async {
    var headers = {
      'x-requested-with': 'XMLHttpRequest',
      'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'cookie': await account.getCookies(),
    };
    if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
    var body = UrlUtil.mapToUrlEncoded({
      'last': '$last',
      'log': log,
      '_referer': '${account.forumUrl}/index.php',
    });
    var targetUrl = '${account.forumUrl}/app.php/mchat/action/refresh';
    var streamedResponse = await (Client().send(
      Request('POST', Uri.parse(targetUrl))
        ..headers.addAll(headers)
        ..body = body,
    ));
    var response = await Response.fromStream(streamedResponse);
    if (response.statusCode >= 400) throw response.body;
    if (DocumentUtil.hasSessionCookie(response.headers)) {
      var cookies = DocumentUtil.extractCookie(response.headers)!;
      await account.updateCookies(cookies);
    }
    if (DocumentUtil.isCloudflare(response.body, account.forumUrl)) {
      await updateCloudflare();
      return await refresh(last, log);
    }
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    List<Message>? add, edit;
    if (json['add'] != null) {
      add = parseMessages(json['add']!, account.forumUrl);
    }
    if (json['edit'] != null) {
      edit = parseMessages(json['edit']!, account.forumUrl);
    }
    return MchatRefreshResponse(
      add: add,
      edit: edit,
      del: handleDel(json['del']),
      log: '${json['log']}',
    );
  }

  Future<MchatRefreshResponse> add({
    required String last,
    required String text,
    required String formToken,
    required String creationTime,
  }) async {
    try {
      var headers = {
        'x-requested-with': 'XMLHttpRequest',
        'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'cookie': await account.getCookies(),
      };
      if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
      var body = UrlUtil.mapToUrlEncoded({
        'last': last,
        'message': text,
        'creation_time': creationTime,
        'form_token': formToken,
      });
      var targetUrl = '${account.forumUrl}/app.php/mchat/action/add';
      var streamedResponse = await (Client().send(
        Request('POST', Uri.parse(targetUrl))
          ..headers.addAll(headers)
          ..body = body,
      ));
      var response = await Response.fromStream(streamedResponse);
      if (response.statusCode >= 400) throw response.body;
      if (DocumentUtil.hasSessionCookie(response.headers)) {
        var cookies = DocumentUtil.extractCookie(response.headers)!;
        await account.updateCookies(cookies);
      }
      if (DocumentUtil.isCloudflare(response.body, account.forumUrl)) {
        await updateCloudflare();
        return await this.add(
          creationTime: creationTime,
          formToken: formToken,
          last: last,
          text: text,
        );
      }
      var json = jsonDecode(response.body) as Map<String, dynamic>;
      List<Message>? add, edit;
      if (json['add'] != null) {
        add = parseMessages(json['add']!, account.forumUrl);
      }
      if (json['edit'] != null) {
        edit = parseMessages(json['edit']!, account.forumUrl);
      }
      return MchatRefreshResponse(
        add: add,
        edit: edit,
        del: handleDel(json['del']),
        log: '${json['log']}',
      );
    } catch (e) {
      logger.error('Error during add $e');
      if (DocumentUtil.isJson(e.toString())) {
        var parsedError = jsonDecode(e.toString()) as Map<String, dynamic>;
        if (parsedError['message'] != null) {
          throw parsedError['message']!;
        }
      }
      throw 'Could not send message to server';
    }
  }

  Future<MchatRefreshResponse> edit({
    required int id,
    required String message,
    required String creationTime,
    required String formToken,
  }) async {
    try {
      var headers = {
        'x-requested-with': 'XMLHttpRequest',
        'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'cookie': await account.getCookies(),
      };
      if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
      var body = UrlUtil.mapToUrlEncoded({
        'message_id': '$id',
        'message': message,
        'page': 'index',
        'creation_time': creationTime,
        'form_token': formToken,
        '_referer': '${account.forumUrl}/index.php',
      });
      var targetUrl = '${account.forumUrl}/app.php/mchat/action/edit';
      var streamedResponse = await (Client().send(
        Request('POST', Uri.parse(targetUrl))
          ..headers.addAll(headers)
          ..body = body,
      ));
      var response = await Response.fromStream(streamedResponse);
      if (response.statusCode >= 400) throw response.body;
      if (DocumentUtil.hasSessionCookie(response.headers)) {
        var cookies = DocumentUtil.extractCookie(response.headers)!;
        await account.updateCookies(cookies);
      }
      if (DocumentUtil.isCloudflare(response.body, account.forumUrl)) {
        await updateCloudflare();
        return await this.edit(
          creationTime: creationTime,
          formToken: formToken,
          id: id,
          message: message,
        );
      }
      var json = jsonDecode(response.body) as Map<String, dynamic>;
      List<Message>? add, edit;
      if (json['add'] != null) {
        add = parseMessages(json['add']!, account.forumUrl);
      }
      if (json['edit'] != null) {
        edit = parseMessages(json['edit']!, account.forumUrl);
      }
      return MchatRefreshResponse(
        add: add,
        edit: edit,
        del: handleDel(json['del']),
        log: '${json['log']}',
      );
    } catch (e) {
      logger.error('Error during edit $e');
      if (DocumentUtil.isJson(e.toString())) {
        var parsedError = jsonDecode(e.toString()) as Map<String, dynamic>;
        if (parsedError['message'] != null) {
          throw parsedError['message']!;
        }
      }
      throw 'Could not send edit request to server';
    }
  }

  Future<MchatRefreshResponse> del({
    required int id,
    required String formToken,
    required String creationTime,
  }) async {
    try {
      var headers = {
        'x-requested-with': 'XMLHttpRequest',
        'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'cookie': await account.getCookies(),
      };
      if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
      var body = UrlUtil.mapToUrlEncoded({
        'message_id': '$id',
        'creation_time': creationTime,
        'form_token': formToken,
        '_referer': '${account.forumUrl}/index.php',
      });
      var targetUrl = '${account.forumUrl}/app.php/mchat/action/del';
      var streamedResponse = await (Client().send(
        Request('POST', Uri.parse(targetUrl))
          ..headers.addAll(headers)
          ..body = body,
      ));
      var response = await Response.fromStream(streamedResponse);
      if (response.statusCode >= 400) throw response.body;
      if (DocumentUtil.hasSessionCookie(response.headers)) {
        var cookies = DocumentUtil.extractCookie(response.headers)!;
        await account.updateCookies(cookies);
      }
      if (DocumentUtil.isCloudflare(response.body, account.forumUrl)) {
        await updateCloudflare();
        return await del(
          creationTime: creationTime,
          formToken: formToken,
          id: id,
        );
      }
      var json = jsonDecode(response.body) as Map<String, dynamic>;
      List<Message>? add, edit;
      if (json['add'] != null) {
        add = parseMessages(json['add']!, account.forumUrl);
      }
      if (json['edit'] != null) {
        edit = parseMessages(json['edit']!, account.forumUrl);
      }
      return MchatRefreshResponse(
        add: add,
        edit: edit,
        del: handleDel(json['del']),
        log: '${json['log']}',
      );
    } catch (e) {
      logger.error('Error during del: $e');
      if (DocumentUtil.isJson(e.toString())) {
        var parsedError = jsonDecode(e.toString()) as Map<String, dynamic>;
        if (parsedError['message'] != null) {
          throw parsedError['message']!;
        }
      }
      throw 'Could not send delete request to server';
    }
  }

  Future<MchatChatModel> fetchArchive(int startIndex) async {
    try {
      var headers = {
        'accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'cookie': await account.getCookies(),
      };
      if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
      var targetUrl =
          '${account.forumUrl}/app.php/mchat/archive?start=$startIndex';
      var streamedResponse = await (Client().send(
        Request('GET', Uri.parse(targetUrl))..headers.addAll(headers),
      ));
      var response = await Response.fromStream(streamedResponse);
      if (DocumentUtil.hasSessionCookie(response.headers)) {
        var cookies = DocumentUtil.extractCookie(response.headers)!;
        await account.updateCookies(cookies);
      }
      if (DocumentUtil.isCloudflare(response.body, account.forumUrl)) {
        await updateCloudflare();
        return await fetchArchive(startIndex);
      }
      var messages = parseMessages(response.body, account.forumUrl);
      for (var message in messages) {
        message.read();
      }
      if (messages.isEmpty) {
        logger.info('No posts found in archive HTML');
      }
      return MchatChatModel(messages: messages);
    } catch (e) {
      logger.error('Error when fetching archive startIndex $startIndex: $e');
      return MchatChatModel();
    }
  }

  List<Message> parseMessages(String html, String baseUrl) {
    var doc = parse(html);
    var messageElements = doc.getElementsByClassName('row mchat-message');
    var likeMessage = DocumentUtil.extractLikeMessage(doc);
    var logId = DocumentUtil.extractLogId(doc);
    List<Message> messages = [];
    for (var element in messageElements) {
      messages.add(
        Message(
          id: int.parse(element.attributes['data-mchat-id']!),
          time: element.attributes['data-mchat-message-time']!,
          user: User(
            id: element.attributes['data-mchat-user-id']!,
            name: element.attributes['data-mchat-username']!,
          ),
          message: InnerMessage(
            baseUrl: account.forumUrl,
            text: element.attributes['data-mchat-message']!,
            html:
                element
                    .getElementsByClassName('mchat-text')
                    .elementAt(0)
                    .innerHtml,
          ),
          avatar: Avatar(
            src: extractAvatarAttribute(
              element,
              'src',
            ).replaceFirst('./..', account.forumUrl),
            width: int.tryParse(extractAvatarAttribute(element, 'width')) ?? 0,
          ),
          likeMessage: likeMessage,
          logId: logId,
        ),
      );
    }
    messages.sort((a, b) => a.id - b.id);
    return messages;
  }

  List<int> handleDel(dynamic del) {
    if (del is int) {
      return [del];
    }
    if (del is List) {
      return List<int>.from(del);
    }
    if (del is String) {
      return [int.parse(del)];
    }
    return [];
  }

  String extractAvatarAttribute(Element element, String attributeName) {
    var avatars = element.getElementsByClassName('avatar');
    if (avatars.isNotEmpty) {
      return avatars.elementAt(0).attributes[attributeName] ?? '';
    }
    var mchatAvatars = element.getElementsByClassName('mchat-avatar');
    return mchatAvatars.elementAt(1).attributes[attributeName] ?? '';
  }

  Future<void> updateCloudflare() async {
    var cloudflareAuthorization =
        await CloudflareService(baseUrl: account.forumUrl).authorizeHeadless();
    account.userAgent = cloudflareAuthorization.userAgent;
    await account.updateCookie(cloudflareAuthorization.cookie);
    await account.save();
  }
}
