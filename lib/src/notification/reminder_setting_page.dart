import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/reminder.dart';

// class Reminder {
//   String time;
//   String days;
//   bool isEnabled;

//   Reminder({required this.time, required this.days, this.isEnabled = true});
// }

class ReminderSettingPage extends StatefulWidget {
  final Reminder reminder;

  const ReminderSettingPage({Key? key, required this.reminder})
    : super(key: key);

  @override
  _ReminderSettingPageState createState() => _ReminderSettingPageState();
}

class _ReminderSettingPageState extends State<ReminderSettingPage> {
  int selectedHour = 0;
  int selectedMinute = 0;
  List<String> selectedDays = [];

  @override
  void initState() {
    super.initState();
    final timeParts = widget.reminder.time.split(':');
    selectedHour = int.tryParse(timeParts[0]) ?? 0;
    selectedMinute = int.tryParse(timeParts[1]) ?? 0;
    selectedDays = widget.reminder.days.split(', ').toList();
  }

  @override
  void dispose() {
    widget.reminder.time =
        '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
    widget.reminder.days = selectedDays.join(', ');
    super.dispose();
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
          buildRepeatButton(context),
          const SizedBox(height: 40),
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
          int value = index + min;
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

  Widget buildRepeatButton(BuildContext context) {
    return InkWell(
      onTap: () => _showRepeatDialog(context),
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
            Expanded(
              child: Text(
                selectedDays.isEmpty ? 'Repeat' : selectedDays.join(', '),
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget buildDeleteButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, null); // Hoặc bạn thêm logic xóa reminder ở đây
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
        "Delete reminder",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showRepeatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => StatefulBuilder(
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

              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      days.map((day) {
                        final isSelected = selectedDays.contains(day);
                        return ListTile(
                          title: Text(day),
                          trailing:
                              isSelected
                                  ? const Icon(Icons.check, color: Colors.blue)
                                  : null,
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                selectedDays.remove(day);
                              } else {
                                selectedDays.add(day);
                              }
                            });
                            setState(() {}); // Cập nhật UI trên trang chính
                          },
                        );
                      }).toList(),
                ),
              );
            },
          ),
    );
  }
}
