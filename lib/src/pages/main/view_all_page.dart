import 'package:flutter/material.dart';

class ViewAllPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const ViewAllPage({Key? key, required this.history}) : super(key: key);

  String getImageForAmount(int amount) {
    if (amount <= 120) return 'assets/coffee_cup.png';
    if (amount >= 450) return 'assets/water_bottle.png';
    if (amount >= 280 && amount <= 320) return 'assets/soda_glass.png';
    return 'assets/water_glass.png';
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
          history.isEmpty
              ? Center(child: Text('No drinking history today'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final item = history[index];
                  final amount = item['amount'];
                  final time = item['time'];
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
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
