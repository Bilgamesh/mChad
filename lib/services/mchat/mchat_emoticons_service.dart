import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/emoticons_response_model.dart';
import 'package:mchad/services/cloudflare/cloudflare_service.dart';
import 'package:mchad/utils/document_util.dart';
import 'package:mchad/utils/logging_util.dart';

var logger = LoggingUtil(module: 'mchat_emoticons_service');

class MchatEmoticonsService {
  MchatEmoticonsService({required this.account});
  final Account account;

  Future<EmoticonsResponse> fetchEmoticons(int? start) async {
    try {
      start ??= 0;
      var headers = {
        'accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'cookie': await account.getCookies(),
      };
      if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
      var targetUrl =
          '${account.forumUrl}/posting.php?mode=smilies&f=0&start=$start';
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
        return await fetchEmoticons(start);
      }
      var doc = parse(response.body);
      var hasNextPage = doc.getElementsByClassName('arrow next').isNotEmpty;
      var result = EmoticonsResponse(hasNextPage: hasNextPage);
      var imgs = doc.querySelectorAll('.inner > a > img');
      for (var img in imgs) {
        var pictureUrl = account.forumUrl + img.attributes['src']!.substring(1);
        var width = img.attributes['width']!;
        var height = img.attributes['height']!;
        var code = img.attributes['alt']!;
        var title = img.attributes['title']!;
        result.addEmoticon(
          pictureUrl: pictureUrl,
          width: int.parse(width),
          height: int.parse(height),
          code: code,
          title: title,
        );
      }
      return result;
    } catch (e) {
      logger.error('Failed to fetch emoticons due to error: $e');
      throw 'Could not connect fetch emoticons from ${account.forumName}';
    }
  }
}
