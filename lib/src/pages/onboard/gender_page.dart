import 'package:flutter/material.dart';
import 'package:water_reminder/src/pages/onboard/weight_page.dart';

class GenderPage extends StatefulWidget {
  final String? initialGender;

  const GenderPage({super.key, this.initialGender});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialGender;
  }

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
              genderTitle(textTheme),
              bottomSpace,
              genderImage(),
              nextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget get topSpace => const SizedBox(height: 50);
  Widget get bottomSpace => const SizedBox(height: 150);

  Widget genderTitle(TextTheme textTheme) {
    return Text(
      "Select Gender",
      textAlign: TextAlign.center,
      style: textTheme.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF19A7CE),
      ),
    );
  }

  Widget genderImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedGender = 'male';
            });
          },
          child: Column(
            children: [
              Image.asset("assets/male.png", height: 100, width: 100),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Text(
                  "Male",
                  style: TextStyle(
                    color:
                        selectedGender == 'male'
                            ? const Color(0xFF146C94)
                            : Colors.grey,
                    fontWeight:
                        selectedGender == 'male'
                            ? FontWeight.bold
                            : FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 70),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedGender = 'female';
            });
          },
          child: Column(
            children: [
              Image.asset("assets/femenine.png", height: 100, width: 100),
              const SizedBox(height: 8),
              Text(
                "Female",
                style: TextStyle(
                  color:
                      selectedGender == 'female'
                          ? const Color(0xFF146C94)
                          : Colors.grey,
                  fontWeight:
                      selectedGender == 'female'
                          ? FontWeight.bold
                          : FontWeight.normal,
                  fontSize: 18,
                ),
              ),
            ],
          ),
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
            if (selectedGender != null) {
              Navigator.pop(context, selectedGender); // Trả lại giá trị
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WeightPage(gender: selectedGender!),
              ),
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
}
