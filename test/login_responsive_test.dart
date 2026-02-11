import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:family_task_app/screens/login_screen.dart';
import 'package:family_task_app/services/auth_service.dart';
import 'package:family_task_app/models/household_model.dart';

// Mock AuthService
class MockAuthService implements AuthService {
  @override
  Future<bool> checkFamilyExists(String id) async {
    return true; // Always find family
  }

  @override
  Future<List<Member>> getFamilyMembers(String id) async {
    return [
      Member(name: 'AdminUser', isAdmin: true),
      Member(name: 'RegularUser', isAdmin: false),
    ];
  }
  
  @override
  Future<void> addMember(String familyId, String name) async {}
  
  @override
  Future<bool> verifyAdmin(String familyId, String password) async {
    return password == '1234';
  }

  @override
  Future<void> registerHousehold({required String familyId, required String adminUser, required String password}) async {}

  @override
  Future<List<TaskConfig>> getTaskConfigs(String familyId) async {
    return [];
  }

  @override
  Future<void> updateMemberToken(String familyId, String memberName, String token) async {}

  @override
  Future<void> removeMember(String familyId, Member member) async {}
  
  @override
  Future<void> addTaskConfig(String familyId, String title, int scenario, int offset) async {}

  @override
  Future<void> removeTaskConfig(String familyId, TaskConfig task) async {}
}

void main() {
  group('Login Flow Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('1. Admin Login Flow (Password Required)', (WidgetTester tester) async {
      bool loginSuccess = false;
      
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(
          authService: mockAuthService,
          onLoginSuccess: (fid, member) {
            loginSuccess = true;
          },
        ),
      ));

      // 1. Enter Family ID
      final familyField = find.byType(TextField).at(0);
      await tester.enterText(familyField, 'test_family');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(); // Wait for async checkFamilyExists

      // Verify "Xin chào" or "Chào mừng trở lại" indicates family found
      expect(find.textContaining('Xin chào!'), findsOneWidget); // Adjusted based on code
      
      // 2. Enter Username "AdminUser"
      final userField = find.byType(TextField).at(1); // Username field appears
      await tester.enterText(userField, 'AdminUser');
      await tester.pumpAndSettle();

      // 3. Click "Tiếp tục"
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      // 4. Verify Password Field appears (because AdminUser is admin)
      expect(find.text('Mật khẩu Admin'), findsOneWidget);
      
      // 5. Enter Correct Password
      final passField = find.byType(TextField).last;
      await tester.enterText(passField, '1234');
      await tester.tap(find.text('Vào Nhà'));
      await tester.pumpAndSettle(); 
      
      // Verify login success callback triggered
      expect(loginSuccess, isTrue);
    });

    testWidgets('2. Member Login Flow (No Password)', (WidgetTester tester) async {
      bool loginSuccess = false;

      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(
          authService: mockAuthService,
          onLoginSuccess: (fid, member) {
            loginSuccess = true;
          },
        ),
      ));

      // 1. Enter Family ID
      await tester.enterText(find.byType(TextField).at(0), 'test_family');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 2. Enter Username "RegularUser"
      await tester.enterText(find.byType(TextField).at(1), 'RegularUser');
      await tester.pumpAndSettle();
      
      // 3. Click "Tiếp tục"
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(); 

      // 4. Verify NO Password Field (Login success immediate)
      expect(find.text('Mật khẩu Admin'), findsNothing);
      
      // Verify Success
      expect(loginSuccess, isTrue);
    });
  });
}
