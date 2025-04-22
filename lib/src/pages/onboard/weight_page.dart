import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

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
          onPressed: () {},
          child: const Text(
            "NEXT",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
