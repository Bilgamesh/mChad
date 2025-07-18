import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @polish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get polish;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'mChad'**
  String get appName;

  /// No description provided for @chatLabelValue.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatLabelValue;

  /// No description provided for @accountsLabelValue.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsLabelValue;

  /// No description provided for @settingsLabelValue.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabelValue;

  /// No description provided for @loginPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Log into phpBB forum'**
  String get loginPageLabel;

  /// No description provided for @addressTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Forum address'**
  String get addressTextFieldHint;

  /// No description provided for @usernameTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameTextFieldHint;

  /// No description provided for @passwordTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordTextFieldHint;

  /// No description provided for @totpTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'One-time password'**
  String get totpTextFieldHint;

  /// No description provided for @backButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButtonLabel;

  /// No description provided for @loginButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButtonLabel;

  /// No description provided for @chatboxHint.
  ///
  /// In en, this message translates to:
  /// **'Type something...'**
  String get chatboxHint;

  /// No description provided for @mChatNotFound.
  ///
  /// In en, this message translates to:
  /// **'mChat not found'**
  String get mChatNotFound;

  /// No description provided for @currentlySelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get currentlySelected;

  /// No description provided for @numberOfUsers.
  ///
  /// In en, this message translates to:
  /// **'Users online'**
  String get numberOfUsers;

  /// No description provided for @chatRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Refreshed'**
  String get chatRefreshed;

  /// No description provided for @chatRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing'**
  String get chatRefreshing;

  /// No description provided for @chatRefreshError.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh chat'**
  String get chatRefreshError;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of'**
  String get logoutConfirmation;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'account'**
  String get account;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @existingUserError.
  ///
  /// In en, this message translates to:
  /// **'Account already added'**
  String get existingUserError;

  /// No description provided for @secondsAgo2.
  ///
  /// In en, this message translates to:
  /// **'seconds ago'**
  String get secondsAgo2;

  /// No description provided for @secondsAgo.
  ///
  /// In en, this message translates to:
  /// **'seconds ago'**
  String get secondsAgo;

  /// No description provided for @secondAgo.
  ///
  /// In en, this message translates to:
  /// **'second ago'**
  String get secondAgo;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @onlineUsers.
  ///
  /// In en, this message translates to:
  /// **'Online users'**
  String get onlineUsers;

  /// No description provided for @colorStyle.
  ///
  /// In en, this message translates to:
  /// **'Color style'**
  String get colorStyle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @defaultLikeMessage.
  ///
  /// In en, this message translates to:
  /// **'Likes this message'**
  String get defaultLikeMessage;

  /// No description provided for @deleteMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get deleteMessageTitle;

  /// No description provided for @deleteMessageConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get deleteMessageConfirmation;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved as'**
  String get imageSaved;

  /// No description provided for @imageSavedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image due to error'**
  String get imageSavedError;

  /// No description provided for @unreadMessages.
  ///
  /// In en, this message translates to:
  /// **'Unread messages'**
  String get unreadMessages;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get editTitle;

  /// No description provided for @transitionAnimations.
  ///
  /// In en, this message translates to:
  /// **'Transition animations'**
  String get transitionAnimations;

  /// No description provided for @emoticons.
  ///
  /// In en, this message translates to:
  /// **'Emoticons'**
  String get emoticons;

  /// No description provided for @bbcodes.
  ///
  /// In en, this message translates to:
  /// **'BBCodes'**
  String get bbcodes;

  /// No description provided for @hiddenUsers.
  ///
  /// In en, this message translates to:
  /// **'Hidden users'**
  String get hiddenUsers;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @authorizingCloudflare.
  ///
  /// In en, this message translates to:
  /// **'Authorizing Cloudflare'**
  String get authorizingCloudflare;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
