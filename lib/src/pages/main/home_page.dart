import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;

  final List<Widget> _screens = [
    Center(child: Text('Report Page')),
    Center(child: ProgressIndicatorWidget()), // Progress Indicator widget
    Center(child: Text('Settings')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _screens[_currentIndex]),
          buildBottomNavigationBar(), // Bottom Navigation Bar will be here
        ],
      ),
    );
  }

  // === Bottom Navigation Bar ===
  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
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
    );
  }
}

const TWO_PI = 3.14 * 2;

class ProgressIndicatorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = 200.0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Progress Indicator")),
        body: Center(
          // This Tween Animation Builder is Just For Demonstration, Do not use this AS-IS in Projects
          // Create and Animation Controller and Control the animation that way.
          child: TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(seconds: 4),
            builder: (context, value, child) {
              int percentage = (value * 100).ceil();
              return Container(
                width: size,
                height: size,
                child: Stack(
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) {
                        return SweepGradient(
                          startAngle: 0.0,
                          endAngle: TWO_PI,
                          stops: [value, value],
                          // 0.0 , 0.5 , 0.5 , 1.0
                          center: Alignment.center,
                          colors: [
                            Color(0xFF19A7CE),
                            Colors.grey.withAlpha(55),
                          ],
                        ).createShader(rect);
                      },
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          //image: DecorationImage(image: Image.asset("assets/images/radial_scale.png").image)
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: size - 40,
                        height: size - 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "$percentage",
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
