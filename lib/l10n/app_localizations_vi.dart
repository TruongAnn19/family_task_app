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
}
