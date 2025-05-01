import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../onboard/gender_page.dart';
import '../onboard/weight_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_reminder/src/service/authentication_service.dart';
import '../../notification/remider_page.dart';
import '../../service/notification_service.dart';
import '../../notification/reminder_setting_page.dart';

class SettingsScreen extends StatefulWidget {
  final String gender;
  final String weight;
  final String goalIntake;
  final VoidCallback onRefresh;

  const SettingsScreen({
    Key? key,
    required this.gender,
    required this.weight,
    required this.goalIntake,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String gender;
  late String weight;
  late String goalIntake;

  @override
  void initState() {
    super.initState();
    gender = widget.gender;
    weight = widget.weight;
    goalIntake = widget.goalIntake;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF1F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'More',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Setting'),
            settingItem(
              icon: Icons.notifications,
              title: 'Water reminders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderPage()),
                );
              },
            ),

            sectionTitle('General'),
            settingItem(icon: Icons.flag, title: 'Goal', value: goalIntake),

            sectionTitle('Personal info'),
            settingItem(
              icon: Icons.male,
              title: 'Gender',
              value: gender,
              onTap: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenderPage(initialGender: gender),
                  ),
                );

                if (result != null) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'gender': result});

                    setState(() {
                      gender = result;
                    });
                  }

                  widget.onRefresh();
                }
              },
            ),
            settingItem(
              icon: Icons.monitor_weight,
              title: 'Weight',
              value: weight,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeightPage(gender: gender),
                  ),
                );
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final doc =
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get();
                  setState(() {
                    weight = doc['weight'].toString();
                    goalIntake = doc['dailyWaterTarget'].toString();
                  });
                }

                widget.onRefresh(); // Cập nhật lại HomePage
              },
            ),

            sectionTitle('App'),
            settingItem(
              icon: Icons.feedback_outlined,
              title: 'Give feedback',
              onTap: () => _showFeedbackDialog(context),
            ),
            settingItem(
              icon: Icons.description_outlined,
              title: 'Terms of use',
              onTap: () => _showTermsOfUseDialog(context),
            ),
            settingItem(
              icon: Icons.logout,
              title: 'Log out',
              onTap: () async {
                await AuthService().signout(context: context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF808080),
        ),
      ),
    );
  }

  Widget settingItem({
    required IconData icon,
    required String title,
    String? value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.blue.withOpacity(0.1),
      highlightColor: Colors.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xff19A7CE), width: 1),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF19A7CE), size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14))),
            if (value != null)
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (title == 'Gender' || title == 'Weight') ...[
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ],
              )
            else
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  int calculateDailyWaterTarget(String gender, int weight) {
    if (gender == 'male') {
      return weight * 37;
    } else {
      return weight * 32;
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController _feedbackController = TextEditingController();
    int _rating = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: const [
                  Icon(Icons.feedback_outlined, color: Color(0xFF19A7CE)),
                  SizedBox(width: 8),
                  Text(
                    "Send Feedback",
                    style: TextStyle(color: Color(0xFF19A7CE)),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Rate your experience:"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color:
                              index < _rating ? Colors.amber : Colors.grey[300],
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Write your feedback...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF19A7CE),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    final feedback = _feedbackController.text.trim();
                    if (_rating > 0 || feedback.isNotEmpty) {
                      final user = FirebaseAuth.instance.currentUser;
                      await FirebaseFirestore.instance
                          .collection('feedbacks')
                          .add({
                            'uid': user?.uid ?? 'anonymous',
                            'email': user?.email ?? '',
                            'rating': _rating,
                            'message': feedback,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Thank you for your feedback!")),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTermsOfUseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF19A7CE)),
              SizedBox(width: 8),
              Text("Terms of Use", style: TextStyle(color: Color(0xFF19A7CE))),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                '''
By using MP Water Reminder, you agree to the following:

• This app is a self-care support tool, not a medical device.
• All hydration goals are suggestions, not professional advice.
• We do not collect or share personal information without your consent.
• You are responsible for setting goals appropriate to your body and health needs.
• Usage data may be used to improve app features and performance.
• We reserve the right to modify these terms at any time.

If you disagree, please discontinue use.
              ''',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF19A7CE)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Future<void> onRefresh() async {
  //   // Add logic to refresh data here, e.g., fetch updated data from a database
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final doc =
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .get();
  //     setState(() {
  //       gender = doc['gender'] ?? gender;
  //       weight = doc['weight'] ?? weight;
  //       goalIntake = doc['goalIntake'] ?? goalIntake;
  //     });
  //   }
  // }
}
