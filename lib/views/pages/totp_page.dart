import 'package:flutter/material.dart';
import 'package:mchad/data/models/account_model.dart';
import 'package:mchad/data/models/mchat_login_model.dart';
import 'package:mchad/services/mchat/mchat_login_service.dart';
import 'package:mchad/utils/logging_util.dart';
import 'package:mchad/utils/modal_util.dart';
import 'package:mchad/views/pages/tabs_page.dart';
import 'package:mchad/views/widgets/dark_mode_button_widget.dart';
import 'package:mchad/views/widgets/keyboard_space_widget.dart';
import 'package:mchad/views/widgets/loading_widget.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/data/globals.dart' as globals;

final logger = LoggingUtil(module: 'login_page');

class TotpPage extends StatefulWidget {
  const TotpPage({
    Key? key,
    required this.loginService,
    required this.address,
    required this.username,
  }) : super(key: key);
  final MchatLoginService loginService;
  final String address, username;

  @override
  _TotpPageState createState() => _TotpPageState();
}

class _TotpPageState extends State<TotpPage> {
  var totpController = TextEditingController();
  var validated = false;
  var loading = false;

  @override
  void initState() {
    totpController.addListener(() {
      setState(() {
        validated = validate();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    totpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appName),
        actions: [DarkModeButtonWidget()],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: switch (loading) {
                true => LoadingWidget(),
                false => ListView(
                  padding: const EdgeInsets.all(20.0),
                  shrinkWrap: true,
                  children: [
                    Icon(Icons.forum_outlined, size: 70.0),
                    SizedBox(height: 20.0),
                    Center(
                      child: Text(
                        AppLocalizations.of(context).loginPageLabel,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      keyboardType: TextInputType.numberWithOptions(),
                      controller: totpController,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      onSubmitted: (value) {
                        if (validated) onSubmit(context);
                      },
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).totpTextFieldHint,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    OutlinedButton(
                      onPressed: switch (validated) {
                        true => (() => onSubmit(context)),
                        false => null,
                      },
                      child: Text(
                        AppLocalizations.of(context).loginButtonLabel,
                      ),
                    ),
                  ],
                ),
              },
            ),
          ),
          KeyboardSpaceWidget(withNavbar: false),
        ],
      ),
    );
  }

  bool validate() {
    return totpController.text.isNotEmpty;
  }

  Future<void> onSubmit(BuildContext context) async {
    try {
      setState(() {
        loading = true;
      });
      var loginData = await widget.loginService.loginWithOtp(
        totpController.text,
      );
      totpController.clear();
      if (!context.mounted) return;
      if (loginData.cookie != null) await onLoginSuccess(context, loginData);
    } catch (e) {
      logger.error(e.toString());
      setState(() {
        loading = false;
      });
      ModalUtil.showError(e);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> onLoginSuccess(
    BuildContext context,
    MchatLoginModel loginData,
  ) async {
    totpController.clear();
    var account = Account(
      userName: widget.username,
      userId: loginData.userId!,
      forumName: loginData.forumName!,
      forumUrl: widget.address,
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
