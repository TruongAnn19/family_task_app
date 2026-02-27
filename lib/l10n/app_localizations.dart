import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('vi'),
  ];

  /// No description provided for @hello.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào,'**
  String get hello;

  /// No description provided for @familyId.
  ///
  /// In vi, this message translates to:
  /// **'ID nhà: {id}'**
  String familyId(String id);

  /// No description provided for @members.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên'**
  String get members;

  /// No description provided for @tasks.
  ///
  /// In vi, this message translates to:
  /// **'Công việc'**
  String get tasks;

  /// No description provided for @todoTasks.
  ///
  /// In vi, this message translates to:
  /// **'🎯 Việc cần làm'**
  String get todoTasks;

  /// No description provided for @familyStatus.
  ///
  /// In vi, this message translates to:
  /// **'🏠 Tình trạng cả nhà'**
  String get familyStatus;

  /// No description provided for @weekNum.
  ///
  /// In vi, this message translates to:
  /// **'Tuần {num}'**
  String weekNum(String num);

  /// No description provided for @viewCalendarAndEvents.
  ///
  /// In vi, this message translates to:
  /// **'Xem lịch & Sự kiện'**
  String get viewCalendarAndEvents;

  /// No description provided for @completedAllTasks.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã hoàn thành hết việc! 🎉'**
  String get completedAllTasks;

  /// No description provided for @swapTaskTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Đổi việc này'**
  String get swapTaskTooltip;

  /// No description provided for @cancelRequest.
  ///
  /// In vi, this message translates to:
  /// **'Hủy yêu cầu'**
  String get cancelRequest;

  /// No description provided for @requestAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã được chấp nhận'**
  String get requestAccepted;

  /// No description provided for @taskCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành'**
  String get taskCompleted;

  /// No description provided for @taskIncomplete.
  ///
  /// In vi, this message translates to:
  /// **'Chưa hoàn thành'**
  String get taskIncomplete;

  /// No description provided for @assignedToYou.
  ///
  /// In vi, this message translates to:
  /// **'Bạn'**
  String get assignedToYou;

  /// No description provided for @assignedToMe.
  ///
  /// In vi, this message translates to:
  /// **'Tôi'**
  String get assignedToMe;

  /// No description provided for @assignedToOther.
  ///
  /// In vi, this message translates to:
  /// **'Phụ trách: {name}'**
  String assignedToOther(String name);

  /// No description provided for @perpetualCalendar.
  ///
  /// In vi, this message translates to:
  /// **'Lịch Vạn Niên'**
  String get perpetualCalendar;

  /// No description provided for @month.
  ///
  /// In vi, this message translates to:
  /// **'Tháng {num}'**
  String month(int num);
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
