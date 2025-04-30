import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/cupertino.dart';
import 'package:water_reminder/src/pages/main/home_page.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize Notification
  static Future<void> init(BuildContext context) async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      android: androidInitSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Khi người dùng nhấn vào notification
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      },
    );

    tz.initializeTimeZones();
  }

  // Hiển thị thông báo foreground (toast)
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

  // Lên lịch thông báo theo giờ cụ thể
  static Future<void> scheduleNotification(TimeOfDay time) async {
    final tz.TZDateTime scheduledTime = _nextInstanceOfTime(time);
    final int id = Random().nextInt(100000);

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
          channelDescription: 'Reminders to drink water',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      // Removed invalid parameter 'dateTimeComponents'
      matchDateTimeComponents: DateTimeComponents.time, // lặp hàng ngày
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // Added parameter
    );
  }

  // Tạo thông điệp theo khung giờ
  static String _getMessageByTime(int hour) {
    if (hour >= 6 && hour < 11) {
      // Buổi sáng
      const morningMessages = [
        "Ngày mới tươi như giọt sương – bạn cũng nên uống một ngụm nước đầu tiên nhé! 🌞",
        "Cốc nước sáng sớm là năng lượng mở màn cho cả ngày! 🚿",
        "Dậy sớm uống nước, bạn giống như cây xanh được tưới mát vậy đó! 🌿",
        "Tự thưởng bản thân một ly nước và nụ cười đầu ngày nào! ☀️",
        "Cơ thể bạn đã ‘online’ chưa? Một ngụm nước để khởi động nhé! 🛫",
      ];
      return morningMessages[Random().nextInt(morningMessages.length)];
    } else if (hour >= 11 && hour < 15) {
      const noonMessages = [
        "Đừng để nắng trưa làm bạn héo – uống nước để giữ sức sống nha! 🌞💧",
        "Bữa trưa ngon hơn khi bạn có đủ nước trong người! 🍱💦",
        "Chút nước – một sự hồi sinh nhẹ giữa ngày dài! 🌊",
        "Bạn giống như pin điện thoại – cần ‘sạc nước’ mỗi trưa! 🔋",
        "Khô môi chưa? Uống nước là cách yêu bản thân giữa ngày! 💙",
      ];
      return noonMessages[Random().nextInt(noonMessages.length)];
    } else if (hour >= 15 && hour < 18) {
      const afternoonMessages = [
        "Đừng để cơ thể ‘đuối pin’ – một ngụm nước giúp bạn lấy lại phong độ! ⚡",
        "Não bộ cần nước để tiếp tục sáng tạo đấy! Uống chút nhé! 🧠💧",
        "Một ly nước = một lần refresh cho bạn! 🔄",
        "Tặng cơ thể bạn một ‘điểm tâm chiều’ – là nước mát lành! 🫖",
        "Chiều nay, bạn uống nước chưa? Hãy làm điều đó cho chính mình! 🤗",
      ];
      return afternoonMessages[Random().nextInt(afternoonMessages.length)];
    } else if (hour >= 18 && hour < 22) {
      const eveningMessages = [
        "Cả ngày đã mệt rồi, một ly nước là món quà cho cơ thể bạn đó! 🎁",
        "Tối về, mọi thứ dịu lại – đừng quên dịu dàng với bản thân bằng nước nhé! 🌙",
        "Một chút nước, một chút thư giãn – bạn xứng đáng mà! 🛋️",
        "Uống nước lúc này như đang vỗ về tâm hồn vậy… 🍵",
        "Bạn đã chăm sóc bản thân tốt chưa? Đừng quên uống nước! 💙",
      ];
      return eveningMessages[Random().nextInt(eveningMessages.length)];
    } else {
      const nightMessages = [
        "Một ngụm nước nhẹ để khép lại ngày dài – ngủ ngon nhé! 💤",
        "Giấc mơ đẹp bắt đầu từ một cơ thể đủ nước! 🌌",
        "Nước là lời chúc ngủ ngon ngọt ngào nhất dành cho bạn! 😴💧",
        "Tắt đèn, tắt lo âu, uống nước và say giấc nào… 🌙✨",
        "Đừng để cơ thể khát khi tâm trí đang nghỉ ngơi – uống nước trước khi ngủ nhé! 🌜",
      ];
      return nightMessages[Random().nextInt(nightMessages.length)];
    }
  }

  // Chuyển TimeOfDay -> tz.TZDateTime gần nhất
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
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

    return scheduled;
  }
}
