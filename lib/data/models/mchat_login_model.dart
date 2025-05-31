class MchatLoginModel {
  MchatLoginModel({
    this.creationTime,
    this.formToken,
    this.sid,
    this.login,
    this.cookie,
    this.userId,
    this.secondFactorRequired,
    this.forumName,
    this.random,
    this.submit,
    this.userAgent,
  });
  final String? creationTime;
  final String? formToken;
  final String? sid;
  final String? login;
  final String? cookie;
  final String? userId;
  final bool? secondFactorRequired;
  final String? forumName;
  final String? random;
  final String? submit;
  final String? userAgent;
}
