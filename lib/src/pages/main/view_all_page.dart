import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewAllPage extends StatefulWidget {
  final List<Map<String, dynamic>> history;
  final Function(int) onUpdateProgress;

  const ViewAllPage({
    Key? key,
    required this.history,
    required this.onUpdateProgress,
  }) : super(key: key);

  @override
  State<ViewAllPage> createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  late List<Map<String, dynamic>> _localHistory;
  int _currentIntake = 0; // Initialize current intake
  double _previousProgress = 0.0; // Initialize previous progress
  final int _goalIntake = 2000; // Define goal intake (e.g., 2000 ml)

  @override
  void initState() {
    super.initState();
    _localHistory = List<Map<String, dynamic>>.from(widget.history);
  }

  String getImageForAmount(int amount) {
    if (amount <= 120) return 'assets/small_glass.png';
    if (amount >= 450) return 'assets/large_bottle.png';
    if (amount >= 280 && amount <= 320) return 'assets/large_glass.png';
    return 'assets/small_bottle.png';
  }

  Future<void> _deleteHistoryItem(
    BuildContext context,
    String docId,
    int amount,
    int index,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Bắt đầu xoá mục lịch sử uống nước
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('drink_history')
          .doc(docId)
          .delete();

      // Cập nhật lại lượng nước đã uống trong Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'todayIntake': FieldValue.increment(-amount), // Giảm số lượng nước
        },
      );

      // Cập nhật lại trạng thái cục bộ
      setState(() {
        _localHistory.removeAt(index); // Xoá mục lịch sử khỏi danh sách cục bộ
        _currentIntake -=
            amount; // Giảm lượng nước đã uống trong trạng thái cục bộ
        _previousProgress = (_currentIntake / _goalIntake).clamp(
          0.0,
          1.0,
        ); // Cập nhật tiến trình
      });

      // Gọi lại phương thức để cập nhật lại thanh tiến trình trên trang chủ
      widget.onUpdateProgress(amount);

      // Hiển thị thông báo khi xoá thành công
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted successfully!')));
    } catch (e) {
      // Xử lý lỗi nếu có
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drinking History'),
        backgroundColor: Color(0xFF19A7CE),
        foregroundColor: Colors.white,
      ),
      body:
          _localHistory.isEmpty
              ? Center(child: Text('No drinking history today'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _localHistory.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final item = _localHistory[index];
                  final amount = item['amount'];
                  final time = item['time'];
                  final docId = item['docId'];
                  final imagePath = getImageForAmount(amount);

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            imagePath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$amount ml',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '$time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              if (docId != null) {
                                _deleteHistoryItem(
                                  context,
                                  docId,
                                  amount,
                                  index,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
