import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:family_task_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {

    testWidgets('TC1: Admin Login -> Dashboard -> Logout -> Member Login',
        (WidgetTester tester) async {
      // ========================================
      // KHỞI ĐỘNG APP
      // ========================================
      app.main();
      
      // Chờ SplashScreen load xong (có CircularProgressIndicator nên
      // KHÔNG dùng pumpAndSettle - nó sẽ chờ mãi)
      // Pump nhiều frame nhỏ để chờ navigation
      for (int i = 0; i < 20; i++) {
        await tester.pump(Duration(milliseconds: 500));
      }

      // ========================================
      // LUỒNG 1: ĐĂNG NHẬP ADMIN
      // ========================================
      debugPrint('=== TC1: Admin Login Flow ===');
      
      // Bước 1: Nhập Family ID
      debugPrint('Step 1: Nhập Family ID "test1"');
      final allFields = find.byType(TextField);
      expect(allFields, findsWidgets, reason: 'Không tìm thấy ô nhập liệu nào');
      await tester.enterText(allFields.first, 'test1');
      await tester.pump(Duration(milliseconds: 500));

      // Bước 2: Nhấn tìm kiếm
      debugPrint('Step 2: Nhấn icon tìm kiếm');
      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsOneWidget, reason: 'Không tìm thấy icon tìm kiếm');
      await tester.tap(searchIcon);
      
      // Chờ Firebase trả kết quả
      for (int i = 0; i < 20; i++) {
        await tester.pump(Duration(milliseconds: 500));
      }

      // Bước 3: Kiểm tra "Xin chào!" hiển thị (family found)
      debugPrint('Step 3: Kiểm tra family found');
      expect(find.text('Xin chào!'), findsOneWidget,
          reason: 'Family "test1" không tìm thấy trên Firebase');
      debugPrint('✅ Family "test1" tìm thấy');

      // Bước 4: Nhập Username admin = "test"
      debugPrint('Step 4: Nhập username "test" (admin)');
      final allFields2 = find.byType(TextField);
      await tester.enterText(allFields2.at(1), 'test');
      await tester.pump(Duration(milliseconds: 500));

      // Bước 5: Nhấn "Tiếp tục"
      debugPrint('Step 5: Nhấn "Tiếp tục"');
      final continueBtn = find.text('Tiếp tục');
      expect(continueBtn, findsOneWidget, reason: 'Không tìm thấy nút Tiếp tục');
      await tester.tap(continueBtn);
      for (int i = 0; i < 10; i++) {
        await tester.pump(Duration(milliseconds: 500));
      }

      // Bước 6: Kiểm tra ô mật khẩu hiển thị (vì test là admin)
      debugPrint('Step 6: Kiểm tra ô mật khẩu Admin hiện ra');
      expect(find.text('Mật khẩu Admin'), findsOneWidget,
          reason: 'Ô mật khẩu Admin KHÔNG hiện ra -> LỖI');
      debugPrint('✅ Ô mật khẩu Admin hiện ra đúng');

      // Bước 7: Nhập mật khẩu
      debugPrint('Step 7: Nhập mật khẩu "1234"');
      final allFields3 = find.byType(TextField);
      await tester.enterText(allFields3.last, '1234');
      await tester.pump(Duration(milliseconds: 500));

      // Bước 8: Nhấn "Vào Nhà"
      debugPrint('Step 8: Nhấn "Vào Nhà"');
      final loginBtn = find.text('Vào Nhà');
      expect(loginBtn, findsOneWidget, reason: 'Không tìm thấy nút Vào Nhà');
      await tester.tap(loginBtn);
      for (int i = 0; i < 20; i++) {
        await tester.pump(Duration(milliseconds: 500));
      }

      // Bước 9: Kiểm tra Dashboard hiển thị
      debugPrint('Step 9: Kiểm tra Dashboard');
      expect(find.text('Xin chào,'), findsOneWidget,
          reason: 'Dashboard không hiển thị "Xin chào,"');
      debugPrint('✅ LUỒNG 1 THÀNH CÔNG: Admin đăng nhập thành công!');

      // ========================================
      // LUỒNG 2: ĐĂNG XUẤT
      // ========================================
      debugPrint('=== TC2: Logout Flow ===');
      
      debugPrint('Step 10: Nhấn nút Đăng xuất');
      final logoutBtn = find.byIcon(Icons.logout);
      expect(logoutBtn, findsOneWidget, reason: 'Không tìm thấy nút Đăng xuất');
      await tester.tap(logoutBtn);
      for (int i = 0; i < 10; i++) {
        await tester.pump(Duration(milliseconds: 500));
      }

      // Kiểm tra quay về Login (qua splash screen trước)
      debugPrint('Step 11: Kiểm tra quay về màn hình Login');
      for (int i = 0; i < 10; i++) {
        await tester.pump(Duration(milliseconds: 500));
      }
      expect(find.text('Chào mừng trở lại'), findsOneWidget,
          reason: 'Không quay về màn hình Login');
      debugPrint('✅ LUỒNG 2 THÀNH CÔNG: Đăng xuất thành công!');

      // ========================================
      // LUỒNG 3: ĐĂNG NHẬP MEMBER (KHÔNG CẦN MẬT KHẨU)
      // ========================================
      debugPrint('=== TC3: Member Login Flow ===');

      debugPrint('Step 12: Nhập Family ID "test1"');
      final familyField2 = find.byType(TextField).first;
      await tester.enterText(familyField2, 'test1');
      await tester.pump(Duration(milliseconds: 500));

      debugPrint('Step 13: Nhấn icon tìm kiếm');
      await tester.tap(find.byIcon(Icons.search));
      for (int i = 0; i < 20; i++) {
        await tester.pump(Duration(milliseconds: 500));
      }

      debugPrint('Step 14: Nhập username "An" (member)');
      final usernameField2 = find.byType(TextField).at(1);
      await tester.enterText(usernameField2, 'An');
      await tester.pump(Duration(milliseconds: 500));

      debugPrint('Step 15: Nhấn "Tiếp tục"');
      await tester.tap(find.text('Tiếp tục'));
      for (int i = 0; i < 20; i++) {
        await tester.pump(Duration(milliseconds: 500));
      }

      // Bước 16: Kiểm tra KHÔNG có ô mật khẩu và vào thẳng Dashboard
      debugPrint('Step 16: Kiểm tra vào Dashboard không cần mật khẩu');
      expect(find.text('Mật khẩu Admin'), findsNothing,
          reason: 'Ô mật khẩu Admin HIỆN RA cho member -> LỖI');
      expect(find.text('Xin chào,'), findsOneWidget,
          reason: 'Dashboard không hiển thị cho member');
      debugPrint('✅ LUỒNG 3 THÀNH CÔNG: Member vào Dashboard không cần password!');

      debugPrint('');
      debugPrint('==============================');
      debugPrint('✅ TẤT CẢ 3 LUỒNG TEST ĐÃ PASS!');
      debugPrint('==============================');
    });
  });
}
