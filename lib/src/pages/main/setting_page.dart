import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../onboard/gender_page.dart';
import '../onboard/weight_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            settingItem(icon: Icons.notifications, title: 'Water reminders'),

            sectionTitle('General'),
            settingItem(icon: Icons.flag, title: 'Goal', value: goalIntake),

            sectionTitle('Personal info'),
            settingItem(
              icon: Icons.male,
              title: 'Gender',
              value: gender,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GenderPage()),
                );
                // Fetch dữ liệu mới
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final doc =
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get();
                  setState(() {
                    gender = doc['gender'] ?? gender;
                  });
                }

                widget.onRefresh(); // Cập nhật lại HomePage
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
            settingItem(icon: Icons.feedback_outlined, title: 'Give feedback'),
            settingItem(
              icon: Icons.description_outlined,
              title: 'Terms of use',
            ),
            settingItem(icon: Icons.logout, title: 'Log out'),
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
            Icon(icon, color: Colors.black54, size: 20),
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
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
