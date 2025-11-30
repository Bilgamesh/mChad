import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/notifiers.dart';
import 'package:mchad/utils/theme_util.dart';
import 'package:mchad/views/pages/init_page.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/data/globals.dart' as globals;

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
            home: InitPage(),
          ),
    );
  }
}
