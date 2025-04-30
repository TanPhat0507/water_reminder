import 'package:flutter/material.dart';

class RepeatReminderPage extends StatefulWidget {
  @override
  State<RepeatReminderPage> createState() => _RepeatReminderPageState();
}

class _RepeatReminderPageState extends State<RepeatReminderPage> {
  // Danh sách các ngày trong tuần
  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  // Mảng để lưu trạng thái chọn hoặc không chọn
  List<bool> selectedDays = [false, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Repeat Reminder',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showRepeatDialog(context);
          },
          child: Text("Select Repeat Days"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF19A7CE),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hiển thị popup cho việc chọn các ngày trong tuần
  void _showRepeatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final days = [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday',
            ];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Repeat Reminder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF146C94),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...days.map((day) {
                    final isSelected = selectedDays.contains(day);
                    return ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      title: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? Color(0xFF146C94) : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        setModalState(() {
                          if (isSelected) {
                            selectedDays.remove(day);
                          } else {
                            selectedDays[days.indexOf(day)] = true;
                          }
                        });
                        setState(() {}); // cập nhật lại UI ở ngoài
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF146C94),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Hàm lấy danh sách các ngày đã chọn
  String getSelectedDays() {
    List<String> selected = [];
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        selected.add(days[i]);
      }
    }
    return selected.join(', ');
  }
}
