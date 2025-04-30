import 'package:flutter/material.dart';
import 'reminder_setting_page.dart';
import '../models/reminder.dart' as models;

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  List<models.Reminder> reminders = [
    models.Reminder(time: '06:00', days: 'Everyday', isEnabled: false),
    models.Reminder(time: '22:00', days: 'Saturday'),
    models.Reminder(
      time: '23:00',
      days: 'Saturday, Monday, Tuesday, Wednesday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Water reminders',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF19A7CE)),
            onPressed: () {
              final newReminder = models.Reminder(
                time: '08:00',
                days: 'Monday',
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReminderSettingPage(reminder: newReminder),
                ),
              ).then((result) {
                if (result != null && result is models.Reminder) {
                  setState(() {
                    reminders.add(result);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: reminders.map((r) => buildReminderItem(r)).toList(),
        ),
      ),
    );
  }

  Widget buildReminderItem(models.Reminder reminder) {
    return InkWell(
      onTap: () async {
        final updatedReminder = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderSettingPage(reminder: reminder),
          ),
        );

        if (updatedReminder != null && updatedReminder is models.Reminder) {
          setState(() {
            int index = reminders.indexOf(reminder);
            if (index != -1) reminders[index] = updatedReminder;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff19A7CE), width: 1),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.black54, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.time,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  reminder.days,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                reminder.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                color: reminder.isEnabled ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  reminder.isEnabled = !reminder.isEnabled;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
