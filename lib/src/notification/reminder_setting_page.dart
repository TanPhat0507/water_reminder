import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder.dart';
import '../service/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fluttertoast/fluttertoast.dart';

class ReminderSettingPage extends StatefulWidget {
  final Reminder reminder;
  final bool isNew;

  const ReminderSettingPage({
    Key? key,
    required this.reminder,
    this.isNew = false,
  }) : super(key: key);

  @override
  State<ReminderSettingPage> createState() => _ReminderSettingPageState();
}

class _ReminderSettingPageState extends State<ReminderSettingPage> {
  int selectedHour = 0;
  int selectedMinute = 0;
  List<String> selectedDays = [];
  String days = '';

  String getFormattedDays() {
    final daysList =
        days
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    const allDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const normalDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

    if (daysList.length == 7 || allDays.every(daysList.contains)) {
      return 'Everyday';
    }

    if (daysList.length == 5 && normalDays.every(daysList.contains)) {
      return 'Normal day';
    }

    return daysList.join(', ');
  }

  int _getWeekdayNumber(String day) {
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

  @override
  void initState() {
    super.initState();
    final parts = widget.reminder.time.split(':');
    selectedHour = int.tryParse(parts[0]) ?? 0;
    selectedMinute = int.tryParse(parts[1]) ?? 0;
    selectedDays = widget.reminder.days.split(', ').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Change reminders",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          buildTimePicker(),
          const SizedBox(height: 20),
          buildRepeatButton(),
          const SizedBox(height: 40),
          buildSaveButton(),
          const SizedBox(height: 16),
          buildDeleteButton(),
        ],
      ),
    );
  }

  Widget buildTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildPickerColumn(
          0,
          23,
          selectedHour,
          (val) => setState(() => selectedHour = val),
        ),
        const Text(
          " : ",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        buildPickerColumn(
          0,
          59,
          selectedMinute,
          (val) => setState(() => selectedMinute = val),
        ),
      ],
    );
  }

  Widget buildPickerColumn(
    int min,
    int max,
    int selected,
    Function(int) onChanged,
  ) {
    return SizedBox(
      height: 150,
      width: 80,
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: selected),
        itemExtent: 40,
        onSelectedItemChanged: onChanged,
        children: List.generate(max - min + 1, (index) {
          final value = index + min;
          return Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 20,
                color:
                    value == selected ? const Color(0xFF146C94) : Colors.grey,
                fontWeight:
                    value == selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildRepeatButton() {
    return InkWell(
      onTap: () => _showRepeatDialog(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF19A7CE)),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Repeat',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedDays.isEmpty ? '' : getFormattedDays(),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSaveButton() {
    return ElevatedButton(
      onPressed: () async {
        final formattedTime =
            '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
        widget.reminder.time = formattedTime;
        widget.reminder.days = selectedDays.join(', ');
        widget.reminder.isEnabled = true;

        // Lưu reminder vào Firestore (tạo hoặc cập nhật)
        await _saveReminderToFirestore(widget.reminder);

        // ⚠️ BẮT BUỘC: Đảm bảo reminder.id đã có sau khi lưu
        if (widget.reminder.id == null) {
          Fluttertoast.showToast(
            msg: "❌ reminder.id is null! Không thể lên lịch",
          );
          return;
        }

        print('🔄 reminder.id: ${widget.reminder.id}');

        // Huỷ thông báo cũ nếu có
        await NotificationService.cancelReminder(widget.reminder.id!);

        // Gọi scheduleAuto và in log xác nhận
        Fluttertoast.showToast(msg: "📅 Đang lên lịch thông báo...");
        print('📤 Gọi scheduleAuto()');

        await NotificationService.scheduleAuto(
          reminderId: widget.reminder.id!,
          time: TimeOfDay(hour: selectedHour, minute: selectedMinute),
          days: selectedDays,
        );

        Fluttertoast.showToast(msg: "✅ Đã lên lịch thành công!");

        // Quay lại màn hình trước
        Navigator.pop(context, widget.reminder);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.blue),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text(
        "Save reminder",
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildDeleteButton() {
    return ElevatedButton(
      onPressed: () async {
        await _deleteReminderFromFirestore(widget.reminder);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.red),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text("Delete reminder", style: TextStyle(color: Colors.red)),
    );
  }

  tz.TZDateTime _nextInstanceOfToday(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Nếu thời gian đã qua, lên lịch cho ngày mai
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  void _showRepeatDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (_, controller) {
            final days = [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday',
            ];
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    controller: controller,
                    itemCount: days.length,
                    separatorBuilder:
                        (context, index) => Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                          height: 1,
                        ),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final isSelected = selectedDays.contains(day);
                      return ListTile(
                        title: Text(day),
                        trailing:
                            isSelected
                                ? const Icon(Icons.check, color: Colors.blue)
                                : null,
                        onTap: () {
                          setModalState(() {
                            isSelected
                                ? selectedDays.remove(day)
                                : selectedDays.add(day);
                          });
                          setState(() {});
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _saveReminderToFirestore(Reminder reminder) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final remindersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reminders');

    final reminderData = {
      'time': reminder.time,
      'days': reminder.days,
      'isEnabled': reminder.isEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (reminder.id != null) {
        await remindersRef.doc(reminder.id).update(reminderData);
      } else {
        final newDoc = await remindersRef.add(reminderData);
        reminder.id = newDoc.id;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Save reminder error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save reminder.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteReminderFromFirestore(Reminder reminder) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || reminder.id == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .doc(reminder.id!)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder deleted.'),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pop(context, 'deleted');
    } catch (e) {
      print('Delete reminder error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete reminder.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
