// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get hello => 'Xin chào,';

  @override
  String familyId(String id) {
    return 'ID nhà: $id';
  }

  @override
  String get members => 'Thành viên';

  @override
  String get tasks => 'Công việc';

  @override
  String get todoTasks => '🎯 Việc cần làm';

  @override
  String get familyStatus => '🏠 Tình trạng cả nhà';

  @override
  String weekNum(String num) {
    return 'Tuần $num';
  }

  @override
  String get viewCalendarAndEvents => 'Xem lịch & Sự kiện';

  @override
  String get completedAllTasks => 'Bạn đã hoàn thành hết việc! 🎉';

  @override
  String get swapTaskTooltip => 'Đổi việc này';

  @override
  String get cancelRequest => 'Hủy yêu cầu';

  @override
  String get requestAccepted => 'Đã được chấp nhận';

  @override
  String get taskCompleted => 'Đã hoàn thành';

  @override
  String get taskIncomplete => 'Chưa hoàn thành';

  @override
  String get assignedToYou => 'Bạn';

  @override
  String get assignedToMe => 'Tôi';

  @override
  String assignedToOther(String name) {
    return 'Phụ trách: $name';
  }

  @override
  String get perpetualCalendar => 'Lịch Vạn Niên';

  @override
  String month(int num) {
    return 'Tháng $num';
  }

  @override
  String get familyIdNotExist => 'Mã nhà chưa tồn tại. Hãy đăng ký mới!';

  @override
  String get enterUsername => 'Vui lòng nhập username';

  @override
  String get memberNotFound => 'Không tìm thấy thành viên. Bạn có thể đăng ký.';

  @override
  String get registerAccount => 'Đăng ký tài khoản';

  @override
  String get familyIdLabel => 'ID nhà (Family ID)';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get cancel => 'Huỷ';

  @override
  String get fillAllInfo => 'Vui lòng điền đủ thông tin';

  @override
  String get familyExistLeavePassEmpty =>
      'ID Nhà đã tồn tại! Để tham gia, vui lòng để trống mật khẩu Admin.';

  @override
  String get memberRegisterSuccess =>
      'Đăng ký thành viên thành công. Bạn có thể đăng nhập.';

  @override
  String get familyNotExistEnterPass =>
      'Nhà chưa tồn tại, vui lòng nhập mật khẩu để tạo nhà mới.';

  @override
  String get createFamilySuccess => 'Tạo nhà và tài khoản admin thành công.';

  @override
  String get register => 'Đăng ký';

  @override
  String get wrongPassword => 'Sai mật khẩu!';

  @override
  String get appTitle => 'Quản Lý Việc Nhà';

  @override
  String get helloExclaim => 'Xin chào!';

  @override
  String get welcomeBack => 'Chào mừng trở lại';

  @override
  String get noAccountRegister => 'Bạn chưa có tài khoản? Đăng ký ngay';

  @override
  String get yourAccount => 'Tài khoản của bạn';

  @override
  String get processing => 'Đang xử lý...';

  @override
  String get continueBtn => 'Tiếp tục';

  @override
  String get adminPassLabel => 'Mật khẩu Admin';

  @override
  String get enterHome => 'Vào Nhà';

  @override
  String get registerOtherAccount => 'Đăng ký tài khoản khác?';

  @override
  String get changeFamilyId => 'Đổi Mã Nhà';

  @override
  String get loadingData => 'Đang tải dữ liệu...';

  @override
  String get scenarioRotate => 'Xoay vòng đều (Mỗi tuần đổi người)';

  @override
  String get scenarioSingle => 'Sống 1 mình';

  @override
  String get scenarioContract => 'Thầu khoán (Một người làm hết tuần)';

  @override
  String get scenarioTurnBased => 'Theo lượt (Ai làm xong mới đến người kế)';

  @override
  String get scenarioRotateDesc =>
      'Ví dụ: Tuần này A làm, tuần sau B làm, tuần tới C làm... cứ thế xoay vòng.';

  @override
  String get scenarioSingleDesc =>
      'Dành cho nhà chỉ có 1 người. Việc này luôn giao cho bạn.';

  @override
  String get scenarioContractDesc =>
      'Chế độ \'Trực nhật\': Người này sẽ làm TẤT CẢ các việc thuộc nhóm này trong cả tuần.';

  @override
  String get scenarioTurnBasedDesc =>
      'Dùng cho việc không cố định (VD: Đổi nước). Khi A bấm \'Xong\', hệ thống sẽ chỉ định B cho lần tới.';

  @override
  String get addNewTask => 'Thêm Việc Mới';

  @override
  String get taskNameLabel => 'Tên công việc';

  @override
  String get taskNameHint => 'VD: Đổ rác, Rửa bát...';

  @override
  String get taskDivisionLabel => 'Cách chia việc:';

  @override
  String get offsetLabel => 'Độ lệch người (Offset)';

  @override
  String get offsetHelperText =>
      'Nhập 1 để người làm việc này KHÁC người làm việc trước đó.';

  @override
  String get saveTask => 'Lưu Công Việc';

  @override
  String get taskManagement => 'Quản Lý Công Việc';

  @override
  String get noTasksYet => 'Chưa có công việc nào';

  @override
  String get tapPlusToAdd => 'Hãy bấm nút + để thêm công việc mới';

  @override
  String get deleteThisTask => 'Xóa việc này?';

  @override
  String areYouSureDeleteTask(String title) {
    return 'Bạn chắc chắn muốn xóa \'$title\'?';
  }

  @override
  String get delete => 'Xóa';

  @override
  String get other => 'Khác';

  @override
  String get addTaskFab => 'Thêm Việc';

  @override
  String get addMember => 'Thêm thành viên';

  @override
  String get memberNameLabel => 'Tên thành viên';

  @override
  String get memberNameHint => 'Ví dụ: Bình';

  @override
  String get add => 'Thêm';

  @override
  String addedMemberToFamily(String name) {
    return 'Đã thêm $name vào nhà!';
  }

  @override
  String get cannotDeleteAdmin => 'Không thể xóa Admin!';

  @override
  String get confirmDelete => 'Xác nhận xóa';

  @override
  String areYouSureDeleteMember(String name) {
    return 'Bạn có chắc muốn xóa $name khỏi nhà không?';
  }

  @override
  String get membersTab => 'Thành Viên';

  @override
  String get headOfHousehold => 'Chủ hộ (Admin)';

  @override
  String get regularMember => 'Thành viên';

  @override
  String get addMemberFab => 'Thêm Thành Viên';

  @override
  String get switchLanguage => 'Đổi Ngôn Ngữ';
}
