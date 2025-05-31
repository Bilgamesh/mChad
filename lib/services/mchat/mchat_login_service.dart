import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/cloudflare_authorization_model.dart';
import 'package:mchad/data/models/mchat_login_model.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart' show parse;
import 'package:mchad/services/cloudflare/cloudflare_service.dart';
import 'package:mchad/utils/document_util.dart';
import 'package:mchad/utils/url_util.dart';

class MchatLoginService {
  MchatLoginService({required this.baseUrl})
    : forumName = UrlUtil.convertUrlToName(baseUrl);

  final String baseUrl;
  final String forumName;

  MchatLoginModel? loginPageData;
  MchatLoginModel? otpData;
  CloudflareAuthorization? cloudflareAuthorization;

  Future<void> init() async {
    loginPageData = await getLoginPageData();
  }

  Future<MchatLoginModel> getLoginPageData() async {
    final targetUrl = '$baseUrl/ucp.php?mode=login';
    Map<String, String> headers = {};
    if (cloudflareAuthorization != null) {
      headers['cookie'] = cloudflareAuthorization!.cookie;
      headers['user-agent'] = cloudflareAuthorization!.userAgent;
    }
    var streamedResponse = await (Client().send(
      Request('GET', Uri.parse(targetUrl))
        ..followRedirects = cloudflareAuthorization != null
        ..headers.addAll(headers),
    ));
    var response = await Response.fromStream(streamedResponse);
    if (DocumentUtil.isCloudflare(response.body, baseUrl) &&
        cloudflareAuthorization == null) {
      cloudflareAuthorization =
          await CloudflareService(baseUrl: baseUrl).authorizeHeadless();
      return await getLoginPageData();
    }
    if (!response.body.contains('dmzx/mchat')) {
      throw 'MChat not found on this page.';
    }
    var doc = parse(response.body);

    loginPageData = MchatLoginModel(
      creationTime: DocumentUtil.findInputData(doc, 'creation_time', 'value'),
      formToken: DocumentUtil.findInputData(doc, 'form_token', 'value'),
      sid: DocumentUtil.findInputData(doc, 'sid', 'value'),
      login: DocumentUtil.findInputData(doc, 'login', 'value'),
      cookie: DocumentUtil.extractCookie(response.headers),
    );

    return loginPageData!;
  }

  Future<MchatLoginModel> loginWithCredentials(
    String username,
    String password,
  ) async {
    if (loginPageData == null) {
      throw 'loginPageData is null. Call getLoginPageData first.';
    }
    if (loginPageData!.cookie == null) {
      throw 'cookie missing from loginPageData';
    }

    if (loginPageData!.sid == null) throw 'sid missing from loginPageData';

    if (loginPageData!.creationTime == null) {
      throw 'creadionTime missing from loginPageData';
    }
    if (loginPageData!.formToken == null) {
      throw 'formToken missing from loginPageData';
    }

    if (loginPageData!.login == null) throw 'login missing from loginPageData';

    final targetUrl = '$baseUrl/ucp.php?mode=login';
    final headers = {
      'content-type': 'application/x-www-form-urlencoded',
      'cookie': loginPageData!.cookie!,
    };
    if (cloudflareAuthorization != null) {
      headers['user-agent'] = cloudflareAuthorization!.userAgent;
      headers['cookie'] =
          '${headers['cookie']} ${cloudflareAuthorization!.cookie}';
    }
    var body = UrlUtil.mapToUrlEncoded({
      'username': username,
      'password': password,
      'creation_time': loginPageData!.creationTime!,
      'form_token': loginPageData!.formToken!,
      'sid': loginPageData!.sid!,
      'login': loginPageData!.login!,
      'redirect': './ucp.php?mode=login',
      'autologin': 'on',
    });
    body += '&redirect=index.php';

    var streamedResponse = await (Client().send(
      Request('POST', Uri.parse(targetUrl))
        ..followRedirects = cloudflareAuthorization != null
        ..body = body
        ..headers.addAll(headers),
    ));
    var response = await Response.fromStream(streamedResponse);

    checkErrors(response);
    if (DocumentUtil.hasSessionCookie(response.headers)) {
      var cookie = DocumentUtil.extractCookie(response.headers);
      if (cloudflareAuthorization != null && cookie != null) {
        cookie = '$cookie ${cloudflareAuthorization!.cookie}';
      }
      return MchatLoginModel(
        cookie: cookie,
        userId: DocumentUtil.extractUserId(cookie!),
        secondFactorRequired: false,
        forumName: forumName,
        userAgent: cloudflareAuthorization?.userAgent,
      );
    }

    var doc = parse(response.body);
    otpData = MchatLoginModel(
      creationTime: DocumentUtil.findInputData(doc, 'creation_time', 'value'),
      formToken: DocumentUtil.findInputData(doc, 'form_token', 'value'),
      random: DocumentUtil.findInputData(doc, 'random', 'value'),
      sid: DocumentUtil.findInputData(doc, 'sid', 'value'),
      submit: DocumentUtil.findInputData(
        doc,
        '#auth_otp > #submit_auth',
        'action',
      ),
      cookie: loginPageData!.cookie,
    );

    return MchatLoginModel(
      cookie: loginPageData!.cookie,
      secondFactorRequired: true,
      forumName: forumName,
    );
  }

  Future<MchatLoginModel> loginWithOtp(String otpCode) async {
    if (loginPageData == null) {
      throw 'loginPageData is null. Call getLoginPageData first.';
    }
    if (otpData == null) {
      throw 'otpData is null. Call loginWithCredentials first.';
    }
    if (otpData!.creationTime == null) {
      throw 'creationTime missing from otpData';
    }
    if (otpData!.formToken == null) throw 'formToken missing from otpData';
    if (otpData!.sid == null) throw 'sid missing from otpData';
    if (otpData!.random == null) throw 'random missing from otpData';

    var targetUrl = '$baseUrl${otpData!.submit}';
    var targetHeaders = {
      'content-type': 'application/x-www-form-urlencoded',
      'cookie': otpData!.cookie!,
    };
    if (cloudflareAuthorization != null) {
      targetHeaders['user-agent'] = cloudflareAuthorization!.userAgent;
      targetHeaders['cookie'] =
          '${targetHeaders['cookie']} ${cloudflareAuthorization!.cookie}';
    }
    var body = UrlUtil.mapToUrlEncoded({
      'creation_time': otpData!.creationTime!,
      'form_token': otpData!.formToken!,
      'sid': otpData!.sid!,
      'random': otpData!.random!,
      'authenticate': otpCode,
      'redirect': 'index.php',
    });

    var streamedResponse = await (Client().send(
      Request('POST', Uri.parse(targetUrl))
        ..followRedirects = cloudflareAuthorization != null
        ..body = body
        ..headers.addAll(targetHeaders),
    ));
    var response = await Response.fromStream(streamedResponse);
    checkErrors(response);
    if (response.statusCode == 302) {
      var cookie = DocumentUtil.extractCookie(response.headers);
      if (cloudflareAuthorization != null && cookie != null) {
        cookie += ' ${cloudflareAuthorization!.cookie}';
      }
      return MchatLoginModel(
        cookie: cookie,
        userId: DocumentUtil.extractUserId(cookie!),
        forumName: forumName,
        userAgent: cloudflareAuthorization?.userAgent,
      );
    }
    throw 'Wrong status code ${response.statusCode}. Expected 302.';
  }

  Future<void> logout(Account account) async {
    var cookie = await account.getCookies();
    var sid = cookie.split('_sid=').elementAt(1).split(';').elementAt(0);
    var targetUrl = '$baseUrl/ucp.php?mode=logout&sid=$sid';
    var headers = {'cookie': cookie};
    if (account.userAgent != null) headers['user-agent'] = account.userAgent!;
    await (Client().send(
      Request('GET', Uri.parse(targetUrl))
        ..followRedirects = cloudflareAuthorization != null
        ..headers.addAll(headers),
    ));
  }

  void checkErrors(Response response) {
    var doc = parse(response.body);
    var errorElements = doc.getElementsByClassName('error');
    if (errorElements.isNotEmpty) {
      throw errorElements.elementAt(0).text.replaceAll(RegExp(r'\s+'), ' ');
    }
  }
}
