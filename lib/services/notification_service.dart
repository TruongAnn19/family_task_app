import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localParams = FlutterLocalNotificationsPlugin();

  // 1. Khởi tạo
  static Future<void> init() async {
    // --- QUAN TRỌNG: NẾU LÀ WEB THÌ DỪNG NGAY ---
    if (kIsWeb) {
      print("[WEB] Bỏ qua Notification Service.");
      return; 
    }
    // --------------------------------------------

    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true, badge: true, sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await _initLocalNotification();
      }
    } catch (e) {
      print("Lỗi init FCM: $e");
    }
  }

  // 2. Lấy Token (Bypass Web)
  static Future<String?> getDeviceToken() async {
    if (kIsWeb) return null; // Web trả về null để không lưu token rác
    try {
      return await _fcm.getToken();
    } catch (e) {
      return null;
    }
  }

  // 3. Subscribe Topic (Bypass Web)
  static Future<void> subscribeToFamilyTopic(String familyId) async {
    if (kIsWeb) return;
    try {
      await _fcm.subscribeToTopic("FAMILY_$familyId");
    } catch (e) {
      print("Lỗi subscribe: $e");
    }
  }

  // 4. Cấu hình Local (Mobile Only)
  static Future<void> _initLocalNotification() async {
    tz.initializeTimeZones(); 
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings = InitializationSettings(
      android: androidSettings, 
    );
    await _localParams.initialize(settings);
  }

  // 5. Hẹn giờ (Mobile Only)
  static Future<void> scheduleSaturdayReminder() async {
    if (kIsWeb) return;

    await _localParams.zonedSchedule(
      0,
      'Cuối tuần rồi!',
      'Đừng quên hoàn thành việc nhà nhé!',
      _nextSaturday9AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel', 
          'Nhắc nhở việc nhà',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime _nextSaturday9AM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    while (scheduledDate.weekday != DateTime.saturday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }

  // 6. Hẹn giờ theo sự kiện Calendar
  static Future<void> scheduleEventReminder(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    if (kIsWeb) return;

    await _localParams.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel',
          'Sự kiện Lịch',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }
}