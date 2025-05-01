import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reminder_setting_page.dart';
import '../models/reminder.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  List<Reminder> reminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRemindersFromFirestore();
  }

  Future<void> _loadRemindersFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('reminders')
            .orderBy('updatedAt', descending: true)
            .get();

    setState(() {
      reminders =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Reminder(
              id: doc.id,
              time: data['time'] ?? '00:00',
              days: data['days'] ?? '',
              isEnabled: data['isEnabled'] ?? true,
            );
          }).toList();
      isLoading = false;
    });
    await _loadRemindersFromFirestore();
  }

  Future<void> _navigateToEdit(Reminder reminder) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReminderSettingPage(reminder: reminder),
      ),
    );

    if (result == 'deleted') {
      _loadRemindersFromFirestore();
    } else if (result is Reminder) {
      _loadRemindersFromFirestore();
    }
  }

  Future<void> _navigateToAddReminder() async {
    final newReminder = Reminder(time: '08:00', days: '');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReminderSettingPage(reminder: newReminder, isNew: true),
      ),
    );

    if (result is Reminder) {
      _loadRemindersFromFirestore();
    }
  }

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
            onPressed: _navigateToAddReminder,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    reminders.isEmpty
                        ? const Text('No reminders found.')
                        : Column(
                          children:
                              reminders
                                  .map((r) => buildReminderItem(r))
                                  .toList(),
                        ),
              ),
    );
  }

  Widget buildReminderItem(Reminder reminder) {
    return InkWell(
      onTap: () => _navigateToEdit(reminder),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xff19A7CE), width: 1),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.black54, size: 20),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.time,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminder.getFormattedDays(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            IconButton(
              iconSize: 32,
              icon: Icon(
                reminder.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                color: reminder.isEnabled ? Colors.blue : Colors.grey,
              ),
              onPressed: () async {
                await _toggleReminderStatus(reminder);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleReminderStatus(Reminder reminder) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || reminder.id == null) return;

    final newStatus = !reminder.isEnabled;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reminders')
        .doc(reminder.id!)
        .update({'isEnabled': newStatus});

    setState(() {
      reminder.isEnabled = newStatus;
    });
  }
}
