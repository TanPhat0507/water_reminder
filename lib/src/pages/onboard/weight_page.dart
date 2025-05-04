import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../main/history_page.dart';

import '../main/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key, required this.gender});

  final String gender;

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  int? selectedWeight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              topSpace,
              weightTitle(textTheme),
              bottomSpace,
              weightImage(),
              nextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget get topSpace => const SizedBox(height: 50);
  Widget get bottomSpace => const SizedBox(height: 100);

  Widget weightTitle(TextTheme textTheme) {
    return Text(
      "What is your weight?",
      textAlign: TextAlign.center,
      style: textTheme.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF19A7CE),
      ),
    );
  }

  Widget weightImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/weight.jpg',
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 20),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 80,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: 22),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedWeight = index + 30;
                  });
                },
                children: List.generate(100, (index) {
                  int weight = index + 30;
                  bool isSelected = weight == selectedWeight;
                  return Center(
                    child: Text(
                      '$weight',
                      style: TextStyle(
                        fontSize: 18,
                        color: isSelected ? Color(0xFF146C94) : Colors.grey,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'kg',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF146C94),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget nextButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 250),
      child: SizedBox(
        width: 250,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF146C94),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () async {
            if (selectedWeight == null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Please select a weight")));
              return;
            }

            await saveUserInfoToFirestore();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: const Text(
            "NEXT",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  //tính lượng nước cần uống dựa trên giới tính và cân nặng
  int calculateDailyWaterTarget(String gender, int weight) {
    if (gender == 'male') {
      return (weight * 37);
    } else {
      return (weight * 32);
    }
  }

  // Lưu thông tin người dùng vào Firestore
  Future<void> saveUserInfoToFirestore() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    String uid = user.uid;

    int dailyWaterTarget = calculateDailyWaterTarget(
      widget.gender,
      selectedWeight!,
    );

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'gender': widget.gender,
      'weight': selectedWeight,
      'dailyWaterTarget': dailyWaterTarget,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
