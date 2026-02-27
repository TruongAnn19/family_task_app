// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello,';

  @override
  String familyId(String id) {
    return 'Family ID: $id';
  }

  @override
  String get members => 'Members';

  @override
  String get tasks => 'Tasks';

  @override
  String get todoTasks => '🎯 To-do Tasks';

  @override
  String get familyStatus => '🏠 Family Status';

  @override
  String weekNum(String num) {
    return 'Week $num';
  }

  @override
  String get viewCalendarAndEvents => 'Calendar & Events';

  @override
  String get completedAllTasks => 'You have completed all tasks! 🎉';

  @override
  String get swapTaskTooltip => 'Swap this task';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get requestAccepted => 'Accepted';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get taskIncomplete => 'Incomplete';

  @override
  String get assignedToYou => 'You';

  @override
  String get assignedToMe => 'Me';

  @override
  String assignedToOther(String name) {
    return 'Assigned to: $name';
  }

  @override
  String get perpetualCalendar => 'Perpetual Calendar';

  @override
  String month(int num) {
    return 'Month $num';
  }
}
