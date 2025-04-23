import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  double _currentIntake = 1200; // Lượng nước đã uống
  double _goalIntake = 1200; // Mục tiêu uống nước

  final List<Map<String, dynamic>> _history = [
    {'time': '9:00', 'amount': 300},
    {'time': '10:00', 'amount': 500},
    {'time': '11:00', 'amount': 700},
    {'time': '22:00', 'amount': 300},
  ];

  final List<Widget> _screens = [
    Center(child: Text('Report Page')),
    Center(child: Text('Home Page')),
    Center(child: Text('Settings')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Home', style: TextStyle(color: Colors.black)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.settings),
            onPressed: () {
              // Your settings action here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting message
            Text(
              'Hi, lytanphat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Progress Ring
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _currentIntake / _goalIntake,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF19A7CE),
                    ),
                  ),
                  Text(
                    '$_currentIntake ml / $_goalIntake ml',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Positioned(
                    bottom: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        // Add more water intake
                      },
                      child: Icon(Icons.add),
                      backgroundColor: Color(0xFF19A7CE),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // History section
            Text(
              'History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.local_drink),
                    title: Text('${_history[index]['time']}'),
                    subtitle: Text('${_history[index]['amount']} ml'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFFF8F4F4),
        selectedItemColor: Color(0xFF19A7CE),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.opacity), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
