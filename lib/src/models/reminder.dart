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
  Reminder.fromMap(Map<String, dynamic> map)
    : id = map['id'],
      time = map['time'],
      days = map['days'],
      isEnabled = map['isEnabled'] ?? true;
  Map<String, dynamic> toMap() {
    return {'id': id, 'time': time, 'days': days, 'isEnabled': isEnabled};
  }
}
