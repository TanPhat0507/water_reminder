import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:water_reminder/src/pages/main/home_page.dart';
import 'package:water_reminder/src/notification/remider_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'water_channel',
      'Water Reminders',
      description: 'Reminders to drink water',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('water_sound'),
      enableVibration: true,
    );

    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
      debugPrint('Channel created: ${channel.id} with sound: ${channel.sound}');
    } catch (e) {
      print("Error creating notification channel: $e");
    }

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        Fluttertoast.showToast(
          msg: "Notification clicked",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16,
        );
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ReminderPage()),
          (route) => false,
        );
      },
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }

  static Future<void> scheduleAuto({
    required String reminderId,
    required TimeOfDay time,
    required List<String> days, // có thể rỗng
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    print('Type of days: ${days.runtimeType}');

    print('Days: $days');

    if (days.isEmpty || days.every((day) => day.trim().isEmpty)) {
      tz.TZDateTime scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      print('Notification scheduled with sound: notification_sound');
      await _notificationsPlugin.zonedSchedule(
        reminderId.hashCode,
        "New alarm!",
        _getMessageByTime(time.hour),
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_channel',
            'Water Reminders',
            channelDescription: 'Reminders to drink water',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'water',
            playSound: true,
            sound: RawResourceAndroidNotificationSound('water_sound'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      for (final day in days) {
        final weekday = _weekdayStringToInt(day);
        final int id = _generateNotificationId(reminderId, weekday);
        final tz.TZDateTime scheduledTime = _nextInstanceOfWeekdayTime(
          time,
          weekday,
        );
        final String message = _getMessageByTime(time.hour);

        await _notificationsPlugin.zonedSchedule(
          id,
          "New alarm!",
          message,
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'water_channel',
              'Water Reminders',
              channelDescription: 'Weekly water reminder',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  static Future<void> cancelReminder(String reminderId) async {
    // Loop through all weekdays (from Monday to Sunday) to cancel the notification
    for (int day = DateTime.monday; day <= DateTime.sunday; day++) {
      final int id = _generateNotificationId(reminderId, day);
      await _notificationsPlugin.cancel(id);
    }
  }

  static void showForegroundToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  static int _generateNotificationId(String reminderId, int weekday) {
    if (reminderId == null || reminderId.isEmpty) {
      throw ArgumentError("Reminder ID cannot be null or empty");
    }
    return reminderId.hashCode + weekday;
  }

  static tz.TZDateTime _nextInstanceOfWeekdayTime(TimeOfDay time, int weekday) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static int _weekdayStringToInt(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  static String _getMessageByTime(int hour) {
    const morning = [
      "Chào buổi sáng! Một ngày tuyệt vời đang đợi bạn 🌞",
      "Thức dậy thôi! Đã đến lúc làm điều tuyệt vời cho hôm nay rồi ☀️",
      "Dậy đi bạn ơi, mặt trời đã mỉm cười với bạn rồi đó 🌤️",
      "Khởi động một ngày mới đầy năng lượng nào! 🚀",
      "Một ngày mới, một cơ hội mới – bắt đầu từ chính bạn! 💪",
    ];
    const noon = [
      "Giữa ngày rồi! Nghỉ ngơi một chút và hít thở sâu bạn nhé 🌼",
      "Đừng quên nạp lại năng lượng cho cơ thể và tinh thần! 🍴💧",
      "Buổi trưa là thời điểm để phục hồi – dành chút thời gian cho chính mình 😌",
      "Giữ vững phong độ nào! Đã đến lúc tái tạo năng lượng 💡",
      "Bạn đã làm rất tốt! Giờ là lúc tạm dừng để tiếp tục mạnh mẽ hơn 🧘‍♂️",
    ];
    const afternoon = [
      "Buổi chiều đến rồi, giữ vững tinh thần và tiếp tục chinh phục nhé! 🔥",
      "Một ngụm nước, một hơi thở sâu – bạn vẫn đang làm rất tốt đấy! 💧",
      "Hãy lắng nghe cơ thể bạn – đã đến lúc tiếp thêm năng lượng 🍵",
      "Chiều nay bạn sẽ làm được điều tuyệt vời. Tin tôi đi! 🌟",
      "Đừng để mệt mỏi ngăn bước bạn – refresh lại thôi! ♻️",
    ];
    const evening = [
      "Tối rồi! Thư giãn một chút và tận hưởng khoảnh khắc yên bình 🌃",
      "Bạn đã cố gắng rất nhiều hôm nay. Giờ là lúc nghỉ ngơi 🌌",
      "Thưởng cho mình chút nước, chút bình yên – bạn xứng đáng 🧘‍♀️",
      "Buông bỏ lo toan, giữ lại sự dịu dàng – bắt đầu bằng một ly nước 🍵",
      "Một buổi tối nhẹ nhàng bắt đầu từ sự chăm sóc bản thân 💙",
    ];
    const night = [
      "Trước khi mơ những giấc mơ đẹp – đừng quên uống chút nước nhé 😴",
      "Giấc ngủ ngon đến từ một cơ thể được yêu thương 💧",
      "Một ngày trọn vẹn kết thúc bằng sự dịu dàng – và một ngụm nước 🌜",
      "Bạn đã làm rất tốt rồi, giờ là lúc nghỉ ngơi thật sâu 💫",
      "Tắt đèn, uống nước và ngủ ngoan – mai lại tiếp tục nhé 💙",
    ];

    if (hour >= 6 && hour < 11)
      return morning[Random().nextInt(morning.length)];
    if (hour >= 11 && hour < 15) return noon[Random().nextInt(noon.length)];
    if (hour >= 15 && hour < 18)
      return afternoon[Random().nextInt(afternoon.length)];
    if (hour >= 18 && hour < 22)
      return evening[Random().nextInt(evening.length)];
    return night[Random().nextInt(night.length)];
  }
}
