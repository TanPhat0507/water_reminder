import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  double _currentIntake = 0; // Lượng nước đã uống trong ngày
  double _goalIntake = 2000; // Mục tiêu uống nước (ml)
  bool _isLoading = true;
  double _scale = 1.0;
  double _customAmount = 0.0;
  double _previousProgress = 0.0;

  // Lượng nước nhập tay
  TextEditingController _waterAmountController = TextEditingController();

  bool _isButtonPressed = false;

  final List<Map<String, dynamic>> _history = []; //lưu lịch sử uống nước

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    checkAndResetIntake();
    fetchDrinkHistory();
    // _screens = [
    //   Center(child: Text('Report Page')),
    //   Center(
    //     child: HomePageContent(
    //       onAddWater: _addWater,
    //       currentIntake: _currentIntake,
    //       goalIntake: _goalIntake,
    //       history: _history,
    //       previousProgress: _previousProgress,
    //     ),
    //   ),
    //   Center(child: Text('Settings')),
    // ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGoalStatus();
    });
    _setupDailyCheck();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _goalIntake = (data?['dailyWaterTarget'] ?? 2000).toDouble();
          _currentIntake =
              (data?['todayIntake'] ?? 0)
                  .toDouble(); //load lượng nước đã uống trong ngày
          _isLoading = false;
        });
      } else {
        setState(() {
          _goalIntake = 2000;
          _currentIntake = 0;
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> updateTodayIntake(int amount) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   final userDoc = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid);

  //   await FirebaseFirestore.instance.runTransaction((transaction) async {
  //     final snapshot = await transaction.get(userDoc);

  //     if (!snapshot.exists) return;

  //     final data = snapshot.data() as Map<String, dynamic>;
  //     final currentIntake = (data['todayIntake'] ?? 0) as int;

  //     transaction.update(userDoc, {
  //       'todayIntake': currentIntake + amount,
  //       'lastUpdatedDate': FieldValue.serverTimestamp(), // update timestamp
  //     });
  //   });
  // }
  Future<void> updateTodayIntake(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    await userDoc.update({
      'todayIntake': FieldValue.increment(amount),
      'lastUpdatedDate': FieldValue.serverTimestamp(),
    });
  }

  // load 4 lần uống gần nhất
  Future<void> fetchDrinkHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('drink_history')
            .orderBy('timestamp', descending: true)
            .limit(4)
            .get();

    final historyData =
        snapshot.docs.map((doc) {
          final data = doc.data();
          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
          final formattedTime =
              timestamp != null
                  ? TimeOfDay.fromDateTime(timestamp).format(context)
                  : TimeOfDay.now().format(
                    context,
                  ); // Nếu null thì lấy giờ hiện tại

          return {'time': formattedTime, 'amount': data['amount']};
        }).toList();

    setState(() {
      _history.clear();
      _history.addAll(historyData);
    });
  }

  void _addWater(int amount) {
    setState(() {
      _previousProgress = (_currentIntake / _goalIntake).clamp(0.0, 1.0);
      _currentIntake += amount;
      _history.add({'time': TimeOfDay.now().format(context), 'amount': amount});
    });
    saveDrinkHistory(amount);
    updateTodayIntake(amount);
    fetchDrinkHistory();

    // Check if goal is reached after adding water
    _checkGoalStatus();
  }

  void _checkGoalStatus() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_currentIntake >= _goalIntake) {
      // Show congratulations if goal is reached
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog(
          Image.asset(
            'assets/congra.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          'Congratulations! 🎉',
          'You\'ve reached your daily water goal of ${_goalIntake.toInt()}ml!',
        );
      });
    } else if (now.isAfter(endOfDay)) {
      // Show fail message if day ended without reaching goal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog(
          Image.asset(
            'assets/opps.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          'Oops!',
          'You didn\'t reach your daily water goal today.',
        );
      });
    }
  }

  void _showAlertDialog(Image imageWidget, String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: EdgeInsets.all(24.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                imageWidget,
                SizedBox(height: 24.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF19A7CE),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text(
                        'Go back home',
                        style: TextStyle(color: Color(0xFF146C94)),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF146C94),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _setupDailyCheck() {
    final now = DateTime.now();
    final midnight = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ); // Next midnight

    final durationUntilMidnight = midnight.difference(now);

    Timer(durationUntilMidnight, () {
      if (mounted) {
        _checkGoalStatus();
        _setupDailyCheck(); // Set up for next day
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _screens = [
      HistoryPage(),
      HomePageContent(
        currentIntake: _currentIntake,
        goalIntake: _goalIntake,
        history: _history,
        previousProgress: _previousProgress,
        onAddWater: _addWater,
      ),
      Center(child: Text('Settings')),
    ];

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

  //Lưu lượng nước + thời gian uống
  Future<void> saveDrinkHistory(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('drink_history')
        .add({'amount': amount, 'timestamp': FieldValue.serverTimestamp()});
  }

  // void _addWater(int amount) {
  //   setState(() {
  //     _previousProgress = (_currentIntake / _goalIntake).clamp(
  //       0.0,
  //       1.0,
  //     ); // Ghi nhớ progress cũ
  //     _currentIntake += amount;
  //     _history.add({'time': TimeOfDay.now().format(context), 'amount': amount});
  //   });
  //   saveDrinkHistory(amount);
  //   updateTodayIntake(amount);
  //   fetchDrinkHistory();
  // }

  Future<void> checkAndResetIntake() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!userDoc.exists) return;

    final data = userDoc.data()!;
    DateTime? lastUpdatedDate;
    if (data['lastUpdatedDate'] != null) {
      lastUpdatedDate = (data['lastUpdatedDate'] as Timestamp).toDate();
    }

    DateTime today = DateTime.now();

    if (lastUpdatedDate == null ||
        lastUpdatedDate.year != today.year ||
        lastUpdatedDate.month != today.month ||
        lastUpdatedDate.day != today.day) {
      // Nếu ngày khác hôm nay => reset
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'todayIntake': 0, 'lastUpdatedDate': FieldValue.serverTimestamp()},
      );

      setState(() {
        _currentIntake = 0;
        _history.clear(); // Nếu bạn cũng muốn clear lịch sử hôm nay
      });
    }
  }
}

class HomePageContent extends StatefulWidget {
  final double currentIntake;
  final double goalIntake;
  final List<Map<String, dynamic>> history;
  final double previousProgress;
  final Function(int) onAddWater;

  const HomePageContent({
    Key? key,
    required this.currentIntake,
    required this.goalIntake,
    required this.history,
    required this.onAddWater,
    required this.previousProgress,
  }) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  // late double _currentIntake;
  // late double _goalIntake;
  double _customAmount = 0.0;
  int? _selectedDropIndex;
  TextEditingController _waterAmountController = TextEditingController();
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    // _currentIntake = widget.currentIntake;
    // _goalIntake = widget.goalIntake;
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
    double currentProgress = (widget.currentIntake / widget.goalIntake).clamp(
      0.0,
      1.0,
    );

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: widget.previousProgress,
          end: currentProgress,
        ),
        duration: Duration(milliseconds: 800),
        builder: (context, value, child) {
          double safeValue = value.clamp(0.0, 1.0);
          double currentMl = (safeValue * widget.goalIntake).toDouble();

          return Container(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 18,
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (rect) {
                    return SweepGradient(
                      startAngle: 0.0,
                      endAngle: 3.14 * 2, //xoay 360
                      center: Alignment.center,
                      stops: [0.0, safeValue, safeValue, 1.0],
                      colors: [
                        Color(0xFF19A7CE),
                        Color(0xFF19A7CE),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ).createShader(rect);
                  },
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.3),
                      //     spreadRadius: 3,
                      //     blurRadius: 5,
                      //     offset: Offset(0, 4),
                      //   ),
                      // ],
                    ),
                  ),
                ),
                Container(
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
                          "${currentMl.toInt()} ml",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF19A7CE),
                          ),
                        ),
                        Text(
                          "/${widget.goalIntake.toInt()} ml",
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
                          _scale = 1.2;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          _scale = 1.0;
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
        return SingleChildScrollView(
          child: Padding(
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
                            scale: _selectedDropIndex == index ? 2.0 : 1.0,
                            duration: Duration(milliseconds: 200),
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
          ),
        );
      },
    );
  }

  void _onSelected(int amount) {
    widget.onAddWater(amount);
  }

  // // === History Section ===
  // Widget buildHistorySection(List<Map<String, dynamic>> history) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'History',
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             TextButton(
  //               onPressed: () {},
  //               child: Text(
  //                 'View all →',
  //                 style: TextStyle(fontSize: 18, color: Color(0xFF19A7CE)),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       SizedBox(height: 8),
  //       Divider(
  //         color: Colors.grey.withOpacity(0.3),
  //         thickness: 2,
  //         indent: 16,
  //         endIndent: 16,
  //       ),
  //       SizedBox(height: 10),
  //       Container(
  //         height: 130,
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           itemCount: history.length,
  //           itemBuilder: (context, index) {
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //               child: Column(
  //                 children: [
  //                   Container(
  //                     width: 80,
  //                     height: 80,
  //                     decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       image: DecorationImage(
  //                         image: AssetImage("assets/glass.png"),
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 4),

  //                   Text(
  //                     '${history[index]['time']}',
  //                     style: TextStyle(fontSize: 12),
  //                   ),
  //                   Text(
  //                     '${history[index]['amount']} ml',
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //       SizedBox(height: 10),
  //     ],
  //   );
  // }
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
                onPressed: () {
                  // TODO: Implement view all page if needed
                },
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
          child:
              history.isEmpty
                  ? Center(child: Text('No drinking history today'))
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
