import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mchad/config/constants.dart';
import 'package:mchad/data/state/notifiers.dart';
import 'package:mchad/utils/theme_util.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/data/state/globals.dart' as globals;
import 'package:mchad/views/pages/login_page.dart';
import 'package:mchad/views/pages/tabs_page.dart';
import 'package:mchad/config/app_initialization.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );

  runApp(MyApp(appInitialization: await initApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appInitialization});
  final AppInitializationData appInitialization;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingsNotifier,
      builder:
          (context, settings, child) => MaterialApp(
            navigatorKey: globals.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'mChad',
            theme: ThemeUtil.createTheme(
              colorScheme: settings.colorScheme,
              animations: settings.transitionAnimations,
              textThemeBuilder: switch (settings.fontIndex) {
                0 => null,
                _ => KAppTheme.textThemes.elementAtOrNull(
                  settings.fontIndex - 1,
                ),
              },
            ),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: settings.locale,
            home: appInitialization.isLoggedIn ? TabsPage() : LoginPage(),
          ),
    );
  }
}
