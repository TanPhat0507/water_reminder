import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  double _currentIntake = 1200; // Lượng nước đã uống
  double _goalIntake = 1200; // Mục tiêu uống nước
  double _customAmount = 0.0;
  // Lượng nước nhập tay
  TextEditingController _waterAmountController = TextEditingController();

  bool _isButtonPressed = false;

  final List<Map<String, dynamic>> _history = [
    {'time': '9:00', 'amount': 300},
    {'time': '10:00', 'amount': 500},
    {'time': '11:00', 'amount': 700},
    {'time': '22:00', 'amount': 300},
  ];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      Center(child: Text('Report Page')),
      Center(
        child: HomePageContent(
          currentIntake: _currentIntake,
          goalIntake: _goalIntake,
          history: _history,
        ),
      ),
      Center(child: Text('Settings')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: buildHeader(),
      ),
      body: Column(
        children: [
          Expanded(child: _screens[_currentIndex]),
          buildBottomNavigationBar(),
        ],
      ),
    );
  }

  // === Header ===
  Widget buildHeader() {
    return AppBar(
      title: Text('Hi, KieuMy', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
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

class HomePageContent extends StatefulWidget {
  final double currentIntake;
  final double goalIntake;
  final List<Map<String, dynamic>> history;

  const HomePageContent({
    Key? key,
    required this.currentIntake,
    required this.goalIntake,
    required this.history,
  }) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late double _currentIntake;
  late double _goalIntake;
  bool _isButtonPressed = false;
  double _scale = 1.0;
  int? _selectedDropIndex;

  @override
  void initState() {
    super.initState();
    _currentIntake = widget.currentIntake;
    _goalIntake = widget.goalIntake;
  }

  @override
  Widget build(BuildContext context) {
    final size = 250.0;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildProgressCircle(size),
          SizedBox(height: 20),
          buildHistorySection(widget.history),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // === Progress Circle Section ===
  Widget buildProgressCircle(double size) {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(seconds: 4),
        builder: (context, value, child) {
          int percentage = (_currentIntake / _goalIntake * 100).toInt();

          return Container(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return SweepGradient(
                      startAngle: 0.0,
                      endAngle: 3.14 * 2,
                      stops: [value, value],
                      center: Alignment.center,
                      colors: [Color(0xFF19A7CE), Colors.grey.withAlpha(55)],
                    ).createShader(rect);
                  },
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  //% lượng nước
                  width: size - 40,
                  height: size - 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_currentIntake ml",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF19A7CE),
                          ),
                        ),
                        Text(
                          "/$_goalIntake ml",
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  child: AnimatedScale(
                    scale: _scale,
                    duration: Duration(milliseconds: 150),
                    curve: Curves.easeOutBack,
                    child: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _scale = 1.2; // Phóng to khi bấm
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          _scale = 1.0; // Trở lại bình thường
                        });
                        _showAddWaterDialog();
                      },
                      onTapCancel: () {
                        setState(() {
                          _scale = 1.0;
                        });
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF19A7CE),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add,
                          size: 35,
                          color: Color(0xFF19A7CE),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddWaterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose water amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 20,
                children:
                    [100, 200, 300, 400].asMap().entries.map((entry) {
                      final index = entry.key;
                      final amount = entry.value;

                      return GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            _selectedDropIndex =
                                index; // Lưu chỉ số giọt nước đang nhấn
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            _selectedDropIndex = null; // Reset về bình thường
                          });
                          Navigator.pop(context);
                          _onSelected(amount);
                        },
                        onTapCancel: () {
                          setState(() {
                            _selectedDropIndex = null;
                          });
                        },
                        child: AnimatedScale(
                          scale: _selectedDropIndex == index ? 1.2 : 1.0,
                          duration: Duration(milliseconds: 150),
                          curve: Curves.easeOutBack,
                          child: Column(
                            children: [
                              Icon(
                                Icons.water_drop,
                                size: 40,
                                color: Colors.blue,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$amount ml',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Or',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _waterAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter custom amount (ml)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Chắc chắn giá trị nhập vào là số
                  setState(() {
                    _customAmount = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_customAmount > 0) {
                    Navigator.pop(context);
                    _onSelected(_customAmount.toInt());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF19A7CE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Add Custom Amount",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSelected(int amount) {
    setState(() {
      _currentIntake += amount;
    });
  }

  //nhập cụ thể lượng nước
  TextEditingController _waterAmountController = TextEditingController();

  // Lưu giá trị nhập tay của người dùng
  double _customAmount = 0.0;

  // === History Section ===
  Widget buildHistorySection(List<Map<String, dynamic>> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View all →',
                  style: TextStyle(fontSize: 18, color: Color(0xFF19A7CE)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Divider(
          color: Colors.grey.withOpacity(0.3),
          thickness: 2,
          indent: 16,
          endIndent: 16,
        ),
        SizedBox(height: 10),
        Container(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: history.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage("assets/glass.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),

                    Text(
                      '${history[index]['time']}',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${history[index]['amount']} ml',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
