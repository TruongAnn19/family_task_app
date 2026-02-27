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

  @override
  String get familyIdNotExist => 'Family ID does not exist. Please register!';

  @override
  String get enterUsername => 'Please enter a username';

  @override
  String get memberNotFound => 'Member not found. You can register.';

  @override
  String get registerAccount => 'Register Account';

  @override
  String get familyIdLabel => 'Family ID';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get cancel => 'Cancel';

  @override
  String get fillAllInfo => 'Please fill in all information';

  @override
  String get familyExistLeavePassEmpty =>
      'Family ID already exists! To join, leave Admin password empty.';

  @override
  String get memberRegisterSuccess =>
      'Member registered successfully. You can log in.';

  @override
  String get familyNotExistEnterPass =>
      'Family doesn\'t exist. Enter password to create a new one.';

  @override
  String get createFamilySuccess =>
      'Family and admin account created successfully.';

  @override
  String get register => 'Register';

  @override
  String get wrongPassword => 'Wrong password!';

  @override
  String get appTitle => 'Family Task App';

  @override
  String get helloExclaim => 'Hello!';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get noAccountRegister => 'Don\'t have an account? Register now';

  @override
  String get yourAccount => 'Your account';

  @override
  String get processing => 'Processing...';

  @override
  String get continueBtn => 'Continue';

  @override
  String get adminPassLabel => 'Admin Password';

  @override
  String get enterHome => 'Enter Home';

  @override
  String get registerOtherAccount => 'Register another account?';

  @override
  String get changeFamilyId => 'Change Family ID';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get scenarioRotate => 'Equal rotation (Change weekly)';

  @override
  String get scenarioSingle => 'Living alone';

  @override
  String get scenarioContract => 'Contract (One person does it all week)';

  @override
  String get scenarioTurnBased =>
      'Turn-based (Next person starts after completion)';

  @override
  String get scenarioRotateDesc =>
      'Example: A does it this week, B next week, C the week after... rotating.';

  @override
  String get scenarioSingleDesc =>
      'For single-person households. This task is always yours.';

  @override
  String get scenarioContractDesc =>
      '\'Duty\' mode: This person does ALL tasks in this group for the whole week.';

  @override
  String get scenarioTurnBasedDesc =>
      'For non-fixed tasks (e.g., changing water). When A clicks \'Done\', the system assigns it to B next time.';

  @override
  String get addNewTask => 'Add New Task';

  @override
  String get taskNameLabel => 'Task Name';

  @override
  String get taskNameHint => 'E.g.: Take out trash, Wash dishes...';

  @override
  String get taskDivisionLabel => 'Task division:';

  @override
  String get offsetLabel => 'Person Offset';

  @override
  String get offsetHelperText =>
      'Enter 1 so the assigned person is DIFFERENT from the previous one.';

  @override
  String get saveTask => 'Save Task';

  @override
  String get taskManagement => 'Task Management';

  @override
  String get noTasksYet => 'No tasks yet';

  @override
  String get tapPlusToAdd => 'Tap the + button to add a new task';

  @override
  String get deleteThisTask => 'Delete this task?';

  @override
  String areYouSureDeleteTask(String title) {
    return 'Are you sure you want to delete \'$title\'?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get other => 'Other';

  @override
  String get addTaskFab => 'Add Task';

  @override
  String get addMember => 'Add Member';

  @override
  String get memberNameLabel => 'Member Name';

  @override
  String get memberNameHint => 'E.g.: John';

  @override
  String get add => 'Add';

  @override
  String addedMemberToFamily(String name) {
    return 'Added $name to the family!';
  }

  @override
  String get cannotDeleteAdmin => 'Cannot delete Admin!';

  @override
  String get confirmDelete => 'Confirm Deletion';

  @override
  String areYouSureDeleteMember(String name) {
    return 'Are you sure you want to remove $name from the family?';
  }

  @override
  String get membersTab => 'Members';

  @override
  String get headOfHousehold => 'Head of Household (Admin)';

  @override
  String get regularMember => 'Member';

  @override
  String get addMemberFab => 'Add Member';

  @override
  String get switchLanguage => 'Switch Language';
}
