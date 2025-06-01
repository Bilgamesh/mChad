import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/mchat_login_model.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/services/mchat/mchat_login_service.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:mchad/utils/modal_util.dart';
import 'package:mchad/utils/url_util.dart';
import 'package:mchad/views/pages/tabs_page.dart';
import 'package:mchad/views/pages/totp_page.dart';
import 'package:mchad/views/widgets/dark_mode_button_widget.dart';
import 'package:mchad/views/widgets/keyboard_space_widget.dart';
import 'package:mchad/views/widgets/loading_widget.dart';
import 'package:mchad/views/widgets/verification_icon_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mchad/data/globals.dart' as globals;

final logger = LoggingUtil(module: 'login_page');

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var validated = false;
  var addressController = TextEditingController();
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var addressFocusNode = FocusNode();
  var addressFocusCount = 0;
  var pageActive = true;
  var loading = false;
  var showPassword = false;
  var addressVerificationStatus = VerificationStatus.none;
  var existingUser = false;

  @override
  void initState() {
    addressController.addListener(() {
      setState(() {
        validated = validate();
      });
    });
    usernameController.addListener(() {
      setState(() {
        validated = validate();
      });
    });
    passwordController.addListener(() {
      setState(() {
        validated = validate();
      });
    });
    addressFocusNode.addListener(onAddressFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    pageActive = false;
    addressController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appName,
          style: TextStyle(fontSize: 22.0),
        ),
        actions: [DarkModeButtonWidget()],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child:
                  loading
                      ? LoadingWidget()
                      : ListView(
                        padding: const EdgeInsets.all(20.0),
                        shrinkWrap: true,
                        children: [
                          Icon(Icons.forum_outlined, size: 70.0),
                          SizedBox(height: 20.0),
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.loginPageLabel,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          TextField(
                            keyboardType: TextInputType.url,
                            controller: addressController,
                            focusNode: addressFocusNode,
                            onTapOutside: (event) {
                              validated = validate();
                              FocusScope.of(context).unfocus();
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              label: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.addressTextFieldHint,
                                  ),
                                  addressVerificationStatus ==
                                          VerificationStatus.error
                                      ? Text(
                                        ' - ${AppLocalizations.of(context)!.mChatNotFound}',
                                        style: TextStyle(color: Colors.red),
                                      )
                                      : SizedBox.shrink(),
                                ],
                              ),
                              suffixIcon: VerificationIconWidget(
                                status: addressVerificationStatus,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          TextField(
                            controller: usernameController,
                            onTapOutside: (event) {
                              validated = validate();
                              FocusScope.of(context).unfocus();
                            },
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              label: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.usernameTextFieldHint,
                                  ),
                                  existingUser
                                      ? Text(
                                        ' - ${AppLocalizations.of(context)!.existingUserError}',
                                        style: TextStyle(color: Colors.red),
                                      )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          TextField(
                            controller: passwordController,
                            onTapOutside: (event) {
                              validated = validate();
                              FocusScope.of(context).unfocus();
                            },
                            onSubmitted:
                                (value) => validated ? onLogin(context) : null,
                            obscureText: !showPassword,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(
                                    context,
                                  )!.passwordTextFieldHint,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  HapticsUtil.vibrate();
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                icon:
                                    showPassword
                                        ? Icon(Icons.visibility_off)
                                        : Icon(Icons.visibility),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          OutlinedButton(
                            onPressed:
                                validated ? () => onLogin(context) : null,
                            child: Text(
                              AppLocalizations.of(context)!.loginButtonLabel,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
          KeyboardSpaceWidget(withNavbar: false),
        ],
      ),
    );
  }

  bool validate() {
    existingUser = isAccountAlreadyAdded();
    if (addressController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      return false;
    }
    if (addressVerificationStatus != VerificationStatus.success) return false;
    if (existingUser) return false;
    return true;
  }

  bool isAccountAlreadyAdded() {
    var accounts = accountsNotifier.value;
    return accounts
        .where(
          (account) =>
              account.userName.toLowerCase() ==
                  usernameController.text.toLowerCase() &&
              account.forumUrl.toLowerCase() ==
                  addressController.text.toLowerCase(),
        )
        .isNotEmpty;
  }

  void onAddressFocusChange() {
    if (!addressFocusNode.hasFocus) {
      onAddressFocusLost();
    } else {
      onAddressFocus();
    }
  }

  void onAddressFocus() {
    addressFocusCount++;
    setState(() {
      addressVerificationStatus = VerificationStatus.none;
      validated = validate();
    });
  }

  Future<void> onAddressFocusLost() async {
    if (addressController.text.isEmpty) {
      setState(() {
        addressVerificationStatus = VerificationStatus.none;
      });
      return;
    }
    var urls = UrlUtil.getAllUrlPermutations(addressController.text);
    var addressFocusCountOld = addressFocusCount;
    setState(() {
      addressVerificationStatus = VerificationStatus.loading;
    });
    var discoverySuccess = await discoverUrl(
      urls,
      () => !pageActive || addressFocusCountOld != addressFocusCount,
    );
    if (discoverySuccess == true) {
      setState(() {
        addressVerificationStatus = VerificationStatus.success;
      });
    } else if (discoverySuccess == false) {
      setState(() {
        addressVerificationStatus = VerificationStatus.error;
      });
    } else if (discoverySuccess == null) {
      setState(() {
        addressVerificationStatus = VerificationStatus.none;
      });
    }
    validated = validate();
  }

  Future<bool?> discoverUrl(
    List<String> urls,
    bool Function() shouldAbort,
  ) async {
    for (var url in urls) {
      if (shouldAbort()) return null;
      try {
        var loginService = MchatLoginService(baseUrl: url);
        await loginService.getLoginPageData();
        addressController.text = url;
        return true;
      } catch (e) {
        logger.error('Failed to discover URL due to error: ${e.toString()}');
      }
    }
    return false;
  }

  void onLogin(BuildContext context) async {
    HapticsUtil.vibrate();
    try {
      setState(() {
        loading = true;
      });
      var loginService = MchatLoginService(baseUrl: addressController.text);
      await loginService.init();
      await Future.delayed(Duration(seconds: 1));
      var loginData = await loginService.loginWithCredentials(
        usernameController.text,
        passwordController.text,
      );
      passwordController.clear();
      if (loginData.secondFactorRequired == false && loginData.cookie != null) {
        if (!context.mounted) return;
        return await onLoginSuccess(context, loginData);
      }
      if (loginData.secondFactorRequired == true) {
        setState(() {
          loading = false;
        });
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TotpPage(
                  loginService: loginService,
                  address: addressController.text,
                  username: usernameController.text,
                ),
          ),
        );
      }
    } catch (e, trace) {
      logger.error(e.toString());
      logger.error(trace.toString());
      passwordController.clear();
      setState(() {
        loading = false;
      });
      ModalUtil.showError(e);
    }
  }

  Future<void> onLoginSuccess(
    BuildContext context,
    MchatLoginModel loginData,
  ) async {
    var account = Account(
      userName: usernameController.text,
      userId: loginData.userId!,
      forumName: loginData.forumName!,
      forumUrl: addressController.text,
      userAgent: loginData.userAgent,
    );
    await account.setCookies(loginData.cookie!);
    await account.save();
    account.select();
    await account.save();
    account.updateNotifiers();
    globals.syncManager.restartAll();
    setState(() {
      loading = false;
    });
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => TabsPage()),
      (route) => false,
    );
  }
}
