import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:water_reminder/src/pages/main/home_page.dart';

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
    );

    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
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
          MaterialPageRoute(builder: (_) => const HomePage()),
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
    if (days.isEmpty) {
      final now = tz.TZDateTime.now(tz.local);
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

      await _notificationsPlugin.zonedSchedule(
        reminderId.hashCode,
        "💧 Time to Hydrate!",
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
            sound: RawResourceAndroidNotificationSound('water_sound'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print('🔔 Scheduled notification for ${scheduled.toString()}');
      Fluttertoast.showToast(
        msg:
            "🔔 Notification scheduled at ${scheduled.hour}:${scheduled.minute}",
      );
    } else {
      // Có chọn ngày => lặp lại hàng tuần
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
          "💧 Time to Hydrate!",
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
          matchDateTimeComponents: DateTimeComponents.time,
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
      "Ngày mới tươi như giọt sương – bạn cũng nên uống một ngụm nước đầu tiên nhé! 🌞",
      "Cốc nước sáng sớm là năng lượng mở màn cho cả ngày! 🚿",
      "Dậy sớm uống nước, bạn giống như cây xanh được tưới mát vậy đó! 🌿",
      "Tự thưởng bản thân một ly nước và nụ cười đầu ngày nào! ☀️",
      "Cơ thể bạn đã ‘online’ chưa? Một ngụm nước để khởi động nhé! 🛫",
    ];
    const noon = [
      "Đừng để nắng trưa làm bạn héo – uống nước để giữ sức sống nha! 🌞💧",
      "Bữa trưa ngon hơn khi bạn có đủ nước trong người! 🍱💦",
      "Chút nước – một sự hồi sinh nhẹ giữa ngày dài! 🌊",
      "Bạn giống như pin điện thoại – cần ‘sạc nước’ mỗi trưa! 🔋",
      "Khô môi chưa? Uống nước là cách yêu bản thân giữa ngày! 💙",
    ];
    const afternoon = [
      "Đừng để cơ thể ‘đuối pin’ – một ngụm nước giúp bạn lấy lại phong độ! ⚡",
      "Não bộ cần nước để tiếp tục sáng tạo đấy! Uống chút nhé! 🧠💧",
      "Một ly nước = một lần refresh cho bạn! 🔄",
      "Tặng cơ thể bạn một ‘điểm tâm chiều’ – là nước mát lành! 🫖",
      "Chiều nay, bạn uống nước chưa? Hãy làm điều đó cho chính mình! 🤗",
    ];
    const evening = [
      "Cả ngày đã mệt rồi, một ly nước là món quà cho cơ thể bạn đó! 🎁",
      "Tối về, mọi thứ dịu lại – đừng quên dịu dàng với bản thân bằng nước nhé! 🌙",
      "Một chút nước, một chút thư giãn – bạn xứng đáng mà! 🛋️",
      "Uống nước lúc này như đang vỗ về tâm hồn vậy… 🍵",
      "Bạn đã chăm sóc bản thân tốt chưa? Đừng quên uống nước! 💙",
    ];
    const night = [
      "Một ngụm nước nhẹ để khép lại ngày dài – ngủ ngon nhé! 💤",
      "Giấc mơ đẹp bắt đầu từ một cơ thể đủ nước! 🌌",
      "Nước là lời chúc ngủ ngon ngọt ngào nhất dành cho bạn! 😴💧",
      "Tắt đèn, tắt lo âu, uống nước và say giấc nào… 🌙✨",
      "Đừng để cơ thể khát khi tâm trí đang nghỉ ngơi – uống nước trước khi ngủ nhé! 🌜",
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
