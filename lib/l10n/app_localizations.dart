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

  /// No description provided for @familyIdNotExist.
  ///
  /// In vi, this message translates to:
  /// **'Mã nhà chưa tồn tại. Hãy đăng ký mới!'**
  String get familyIdNotExist;

  /// No description provided for @enterUsername.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập username'**
  String get enterUsername;

  /// No description provided for @memberNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy thành viên. Bạn có thể đăng ký.'**
  String get memberNotFound;

  /// No description provided for @registerAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký tài khoản'**
  String get registerAccount;

  /// No description provided for @familyIdLabel.
  ///
  /// In vi, this message translates to:
  /// **'ID nhà (Family ID)'**
  String get familyIdLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordLabel;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get cancel;

  /// No description provided for @fillAllInfo.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng điền đủ thông tin'**
  String get fillAllInfo;

  /// No description provided for @familyExistLeavePassEmpty.
  ///
  /// In vi, this message translates to:
  /// **'ID Nhà đã tồn tại! Để tham gia, vui lòng để trống mật khẩu Admin.'**
  String get familyExistLeavePassEmpty;

  /// No description provided for @memberRegisterSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành viên thành công. Bạn có thể đăng nhập.'**
  String get memberRegisterSuccess;

  /// No description provided for @familyNotExistEnterPass.
  ///
  /// In vi, this message translates to:
  /// **'Nhà chưa tồn tại, vui lòng nhập mật khẩu để tạo nhà mới.'**
  String get familyNotExistEnterPass;

  /// No description provided for @createFamilySuccess.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhà và tài khoản admin thành công.'**
  String get createFamilySuccess;

  /// No description provided for @register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get register;

  /// No description provided for @wrongPassword.
  ///
  /// In vi, this message translates to:
  /// **'Sai mật khẩu!'**
  String get wrongPassword;

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản Lý Việc Nhà'**
  String get appTitle;

  /// No description provided for @helloExclaim.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào!'**
  String get helloExclaim;

  /// No description provided for @welcomeBack.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng trở lại'**
  String get welcomeBack;

  /// No description provided for @noAccountRegister.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có tài khoản? Đăng ký ngay'**
  String get noAccountRegister;

  /// No description provided for @yourAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản của bạn'**
  String get yourAccount;

  /// No description provided for @processing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý...'**
  String get processing;

  /// No description provided for @continueBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get continueBtn;

  /// No description provided for @adminPassLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu Admin'**
  String get adminPassLabel;

  /// No description provided for @enterHome.
  ///
  /// In vi, this message translates to:
  /// **'Vào Nhà'**
  String get enterHome;

  /// No description provided for @registerOtherAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký tài khoản khác?'**
  String get registerOtherAccount;

  /// No description provided for @changeFamilyId.
  ///
  /// In vi, this message translates to:
  /// **'Đổi Mã Nhà'**
  String get changeFamilyId;

  /// No description provided for @loadingData.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải dữ liệu...'**
  String get loadingData;

  /// No description provided for @scenarioRotate.
  ///
  /// In vi, this message translates to:
  /// **'Xoay vòng đều (Mỗi tuần đổi người)'**
  String get scenarioRotate;

  /// No description provided for @scenarioSingle.
  ///
  /// In vi, this message translates to:
  /// **'Sống 1 mình'**
  String get scenarioSingle;

  /// No description provided for @scenarioContract.
  ///
  /// In vi, this message translates to:
  /// **'Thầu khoán (Một người làm hết tuần)'**
  String get scenarioContract;

  /// No description provided for @scenarioTurnBased.
  ///
  /// In vi, this message translates to:
  /// **'Theo lượt (Ai làm xong mới đến người kế)'**
  String get scenarioTurnBased;

  /// No description provided for @scenarioRotateDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: Tuần này A làm, tuần sau B làm, tuần tới C làm... cứ thế xoay vòng.'**
  String get scenarioRotateDesc;

  /// No description provided for @scenarioSingleDesc.
  ///
  /// In vi, this message translates to:
  /// **'Dành cho nhà chỉ có 1 người. Việc này luôn giao cho bạn.'**
  String get scenarioSingleDesc;

  /// No description provided for @scenarioContractDesc.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ \'Trực nhật\': Người này sẽ làm TẤT CẢ các việc thuộc nhóm này trong cả tuần.'**
  String get scenarioContractDesc;

  /// No description provided for @scenarioTurnBasedDesc.
  ///
  /// In vi, this message translates to:
  /// **'Dùng cho việc không cố định (VD: Đổi nước). Khi A bấm \'Xong\', hệ thống sẽ chỉ định B cho lần tới.'**
  String get scenarioTurnBasedDesc;

  /// No description provided for @addNewTask.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Việc Mới'**
  String get addNewTask;

  /// No description provided for @taskNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên công việc'**
  String get taskNameLabel;

  /// No description provided for @taskNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Đổ rác, Rửa bát...'**
  String get taskNameHint;

  /// No description provided for @taskDivisionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Cách chia việc:'**
  String get taskDivisionLabel;

  /// No description provided for @offsetLabel.
  ///
  /// In vi, this message translates to:
  /// **'Độ lệch người (Offset)'**
  String get offsetLabel;

  /// No description provided for @offsetHelperText.
  ///
  /// In vi, this message translates to:
  /// **'Nhập 1 để người làm việc này KHÁC người làm việc trước đó.'**
  String get offsetHelperText;

  /// No description provided for @saveTask.
  ///
  /// In vi, this message translates to:
  /// **'Lưu Công Việc'**
  String get saveTask;

  /// No description provided for @taskManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản Lý Công Việc'**
  String get taskManagement;

  /// No description provided for @noTasksYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có công việc nào'**
  String get noTasksYet;

  /// No description provided for @tapPlusToAdd.
  ///
  /// In vi, this message translates to:
  /// **'Hãy bấm nút + để thêm công việc mới'**
  String get tapPlusToAdd;

  /// No description provided for @deleteThisTask.
  ///
  /// In vi, this message translates to:
  /// **'Xóa việc này?'**
  String get deleteThisTask;

  /// No description provided for @areYouSureDeleteTask.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chắc chắn muốn xóa \'{title}\'?'**
  String areYouSureDeleteTask(String title);

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @other.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get other;

  /// No description provided for @addTaskFab.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Việc'**
  String get addTaskFab;

  /// No description provided for @addMember.
  ///
  /// In vi, this message translates to:
  /// **'Thêm thành viên'**
  String get addMember;

  /// No description provided for @memberNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên thành viên'**
  String get memberNameLabel;

  /// No description provided for @memberNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: Bình'**
  String get memberNameHint;

  /// No description provided for @add.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get add;

  /// No description provided for @addedMemberToFamily.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm {name} vào nhà!'**
  String addedMemberToFamily(String name);

  /// No description provided for @cannotDeleteAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa Admin!'**
  String get cannotDeleteAdmin;

  /// No description provided for @confirmDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa'**
  String get confirmDelete;

  /// No description provided for @areYouSureDeleteMember.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa {name} khỏi nhà không?'**
  String areYouSureDeleteMember(String name);

  /// No description provided for @membersTab.
  ///
  /// In vi, this message translates to:
  /// **'Thành Viên'**
  String get membersTab;

  /// No description provided for @headOfHousehold.
  ///
  /// In vi, this message translates to:
  /// **'Chủ hộ (Admin)'**
  String get headOfHousehold;

  /// No description provided for @regularMember.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên'**
  String get regularMember;

  /// No description provided for @addMemberFab.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Thành Viên'**
  String get addMemberFab;
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
