// import 'package:flutter/material.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xffF1F2F7),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           'More',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Settings Options
//             Text(
//               "Setting",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xff212C42),
//               ),
//             ),
//             const SizedBox(height: 10),

//             supportTile(icon: Icons.help_outline, title: "Water Reminder"),

//             Text(
//               "General",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xff212C42),
//               ),
//             ),
//             const SizedBox(height: 10),

//             settingTile(icon: Icons.notifications, title: "Goal"),

//             const SizedBox(height: 30),

//             Text(
//               "Personal Info",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xff212C42),
//               ),
//             ),
//             const SizedBox(height: 10),

//             supportTile(icon: Icons.help_outline, title: "Gender"),
//             supportTile(icon: Icons.mail_outline, title: "Weight"),
//             supportTile(icon: Icons.info_outline, title: "About App"),

//             Text(
//               "App",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xff212C42),
//               ),
//             ),
//             const SizedBox(height: 10),

//             supportTile(icon: Icons.help_outline, title: "Give feedback"),
//             supportTile(icon: Icons.mail_outline, title: "Terms of use"),
//             supportTile(icon: Icons.info_outline, title: "Log out"),
//           ],
//         ),
//       ),
//     );
//   }

//   // Setting Item Widget
//   Widget settingTile({required IconData icon, required String title}) {
//     return Card(
//       color: Color(0xffEDEFFE),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ListTile(
//         leading: Icon(icon, color: Color(0xff9CA2FF)),
//         title: Text(title),
//         trailing: Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: () {},
//       ),
//     );
//   }

//   // Support Item Widget
//   Widget supportTile({required IconData icon, required String title}) {
//     return Card(
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ListTile(
//         leading: Icon(icon, color: Color(0xff212C42)),
//         title: Text(title),
//         trailing: Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: () {},
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
            settingItem(icon: Icons.flag, title: 'Goal', value: '1200ml'),

            sectionTitle('Personal info'),
            settingItem(icon: Icons.male, title: 'Gender', value: 'Male'),
            settingItem(
              icon: Icons.monitor_weight,
              title: 'Weight',
              value: '52kg',
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.opacity), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
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
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget settingItem({
    required IconData icon,
    required String title,
    String? value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff19A7CE), width: 1),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title),
        trailing:
            value != null
                ? Text(
                  value,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
