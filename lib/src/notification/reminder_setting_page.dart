import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder.dart';

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

  Widget buildSaveButton() {
    return ElevatedButton(
      onPressed: () async {
        widget.reminder.time =
            '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
        widget.reminder.days = selectedDays.join(', ');
        widget.reminder.isEnabled = true;

        await _saveReminderToFirestore(widget.reminder);
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

  void _showRepeatDialog() {
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
                            setState(() {});
                          },
                        );
                      }).toList(),
                ),
              );
            },
          ),
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

    if (reminder.id != null) {
      // Update existing
      await remindersRef.doc(reminder.id).update(reminderData);
    } else {
      // Create new
      final newDoc = await remindersRef.add(reminderData);
      reminder.id = newDoc.id;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteReminderFromFirestore(Reminder reminder) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || reminder.id == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reminders')
        .doc(reminder.id)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder deleted.'),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context, null); // Trả null để xóa khỏi danh sách ngoài
  }
}
