import 'package:flutter/material.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/utils/haptics_util.dart';
import 'package:mchad/views/pages/login_page.dart';

class LoginButtonWidget extends StatelessWidget {
  const LoginButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: Icon(Icons.login),
      label: Text(AppLocalizations.of(context).loginButtonLabel),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () {
        HapticsUtil.vibrate();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
    );
  }
}
