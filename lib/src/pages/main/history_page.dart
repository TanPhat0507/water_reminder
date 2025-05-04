import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<bool> isSelected = [true, false];
  List<Map<String, dynamic>> weeklyData = [];
  List<Map<String, dynamic>> monthlyData = [];
  bool isLoading = true;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchDrinkHistory();
    _setupRealTimeListener();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupRealTimeListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('drink_history')
        .snapshots()
        .listen((_) {
          _fetchDrinkHistory();
        });
  }

  String _getRangeText() {
    if (isSelected[0]) {
      // Nếu đang ở chế độ tuần
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));
      final formatter = DateFormat('dd/MM/yyyy');
      return '${formatter.format(startOfWeek)} - ${formatter.format(endOfWeek)}';
    } else {
      // Nếu đang ở chế độ năm (12 tháng)
      final now = DateTime.now();
      final startMonth = DateTime(now.year, now.month - 11);
      final formatter = DateFormat('MM/yyyy');
      return '${formatter.format(startMonth)} - ${formatter.format(now)}';
    }
  }

  Future<void> _fetchDrinkHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Lấy dữ liệu 7 ngày gần nhất
    final weekAgo = DateTime.now().subtract(Duration(days: 7));
    final weekSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('drink_history')
            .where('timestamp', isGreaterThanOrEqualTo: weekAgo)
            .orderBy('timestamp')
            .get();

    // Lấy dữ liệu 12 tháng gần nhất
    final yearAgo = DateTime.now().subtract(Duration(days: 365));
    final monthSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('drink_history')
            .where('timestamp', isGreaterThanOrEqualTo: yearAgo)
            .orderBy('timestamp')
            .get();

    // Xử lý dữ liệu theo tuần
    weeklyData = _processWeeklyData(weekSnapshot.docs);

    // Xử lý dữ liệu theo tháng
    monthlyData = _processMonthlyData(monthSnapshot.docs);

    setState(() {
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> _processWeeklyData(
    List<QueryDocumentSnapshot> docs,
  ) {
    Map<String, double> dailyTotals = {};

    // Khởi tạo 7 ngày gần nhất với giá trị 0
    for (int i = 6; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String dayKey = DateFormat('EE').format(date);
      dailyTotals[dayKey] = 0;
    }

    // Tính tổng lượng nước theo ngày
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final day = DateFormat('EE').format(timestamp);
      final amount = (data['amount'] as num).toDouble();

      if (dailyTotals.containsKey(day)) {
        dailyTotals[day] = dailyTotals[day]! + amount;
      }
    }

    return dailyTotals.entries
        .map((e) => {'day': e.key, 'amount': e.value})
        .toList();
  }

  List<Map<String, dynamic>> _processMonthlyData(
    List<QueryDocumentSnapshot> docs,
  ) {
    Map<String, double> monthlyTotals = {};

    // Khởi tạo 12 tháng gần nhất với giá trị 0
    for (int i = 11; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: 30 * i));
      String monthKey = DateFormat('MM').format(date);
      monthlyTotals[monthKey] = 0;
    }

    // Tính tổng lượng nước theo tháng
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final month = DateFormat('MM').format(timestamp);
      final amount = (data['amount'] as num).toDouble();

      if (monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = monthlyTotals[month]! + amount;
      }
    }

    return monthlyTotals.entries
        .map((e) => {'month': e.key, 'amount': e.value})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildToggleButtons(),
                  SizedBox(height: 10),
                  Text(
                    _getRangeText(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            buildChart(),
          ],
        ),
      ),
    );
  }

  Widget buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 16.0, right: 24.0),
      child: ToggleButtons(
        isSelected: isSelected,
        onPressed: (int index) {
          setState(() {
            for (int i = 0; i < isSelected.length; i++) {
              isSelected[i] = i == index;
            }
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Week'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Year'),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        fillColor: Color(0xFF146C94),
        color: Color(0xFF146C94),
        constraints: BoxConstraints(minHeight: 40, minWidth: 100),
      ),
    );
  }

  Widget buildChart() {
    final currentData = isSelected[0] ? weeklyData : monthlyData;
    final maxY =
        (currentData.map((e) => e['amount']).reduce((a, b) => a > b ? a : b) *
                1.2)
            .toDouble();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Text(
              //   'ml',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              SizedBox(height: 8),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: maxY / 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 && value < currentData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  isSelected[0]
                                      ? currentData[value.toInt()]['day']
                                      : currentData[value.toInt()]['month'],
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(currentData.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: currentData[index]['amount'].toDouble(),
                            width: 16,
                            color: Color(0xFF19A7CE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
