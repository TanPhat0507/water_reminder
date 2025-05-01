import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  String? id;
  String time;
  String days;
  bool isEnabled;

  Reminder({
    this.id,
    required this.time,
    required this.days,
    this.isEnabled = true,
  });

  factory Reminder.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      time: data['time'] ?? '',
      days: data['days'] ?? '',
      isEnabled: data['isEnabled'] ?? true,
    );
  }
  Map<String, dynamic> toMap() {
    return {'time': time, 'days': days, 'isEnabled': isEnabled};
  }
}

extension ReminderFormatter on Reminder {
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
}
