import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/online_users_response_model.dart';
import 'package:mchad/services/cloudflare/cloudflare_service.dart';
import 'package:mchad/utils/document_util.dart';
import 'package:mchad/utils/logging_util.dart';

var logger = LoggingUtil(module: 'mchat_users_service');

class MchatUsersService {
  MchatUsersService({required this.account});
  final Account account;

  Future<Account> fetchUserProfile() async {
    try {
      var headers = {
        'accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'cookie': await account.getCookies(),
      };
      if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
      var targetUrl =
          '${account.forumUrl}/memberlist.php?mode=viewprofile&u=${account.userId}';
      var streamedResponse = await (Client().send(
        Request('GET', Uri.parse(targetUrl))..headers.addAll(headers),
      ));
      var response = await Response.fromStream(streamedResponse);
      if (DocumentUtil.hasSessionCookie(response.headers)) {
        var cookies = DocumentUtil.extractCookie(response.headers)!;
        await account.updateCookies(cookies);
      }
      var doc = parse(response.body);
      var avatarUrl =
          doc.getElementsByClassName('avatar').isNotEmpty
              ? (account.forumUrl +
                  doc
                      .getElementsByClassName('avatar')
                      .elementAt(0)
                      .attributes['src']!
                      .substring(1))
              : null;
      String? userName;
      if (doc.getElementsByClassName('username').isNotEmpty) {
        userName =
            doc.getElementsByClassName('username').elementAt(0).innerHtml;
      } else {
        userName =
            doc
                .getElementsByClassName('username-coloured')
                .elementAt(0)
                .innerHtml;
      }
      return Account(
        avatarUrl: avatarUrl,
        userName: userName,
        userId: account.userId,
        forumName: account.forumName,
        forumUrl: account.forumUrl,
      );
    } catch (e) {
      logger.error('Failed to fetch user profile due to error: $e');
      throw 'Could not connect fetch user profile from ${account.forumName}';
    }
  }

  Future<OnlineUsersResponse> fetchOnlineUsers() async {
    try {
      var headers = {
        'accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'cookie': await account.getCookies(),
      };
      if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
      var targetUrl = '${account.forumUrl}/viewonline.php';
      var streamedResponse = await (Client().send(
        Request('GET', Uri.parse(targetUrl))..headers.addAll(headers),
      ));
      var response = await Response.fromStream(streamedResponse);
      if (DocumentUtil.hasSessionCookie(response.headers)) {
        var cookies = DocumentUtil.extractCookie(response.headers)!;
        await account.updateCookies(cookies);
      }
      if (DocumentUtil.isCloudflare(response.body, account.forumUrl)) {
        var cloudflareAuthorization =
            await CloudflareService(
              baseUrl: account.forumUrl,
            ).authorizeHeadless();
        account.userAgent = cloudflareAuthorization.userAgent;
        await account.updateCookie(cloudflareAuthorization.cookie);
        await account.save();
        return await fetchOnlineUsers();
      }
      var doc = parse(response.body);
      var message = doc.querySelector('.viewonline-title')!.text;
      var table = doc.querySelector('tbody');
      List<String> users = [];
      List<String> userIds = [];
      List<String> bots = [];
      for (var row in table!.children) {
        var user = row.querySelector('[class^=username][href]')?.text;
        var userId =
            row
                .querySelector('[class^=username][href]')
                ?.attributes['href']
                ?.split('&u=')
                .lastOrNull;
        var bot = row.querySelector('[class^=username]:not([href])')?.text;
        if (user != null) users.add(user);
        if (userId != null) userIds.add(userId);
        if (bot != null) bots.add(bot);
      }
      var regExp = RegExp(r'\d+');
      var matches = regExp.allMatches(message);
      var counts = matches.map((match) => int.parse(match.group(0)!)).toList();
      var totalCount =
          counts.fold(0, (int accumulator, int currentValue) {
            return accumulator + currentValue;
          }) -
          bots.length;
      return OnlineUsersResponse(
        message: message,
        users: users,
        userIds: userIds,
        bots: bots,
        totalCount: totalCount,
      );
    } catch (e) {
      logger.error('Failed to fetch online users due to error: $e');
      throw 'Could not connect fetch online users from ${account.forumName}';
    }
  }
}
