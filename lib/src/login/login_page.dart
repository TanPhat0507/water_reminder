import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    auth.authStateChanges().listen((event) {
      setState(() {
        user = event;
      });
    });
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
              loginImage,
              appTitle(textTheme),
              appSubtitle,
              bottomSpace,
              googleSignInButton(),
              smallSpace,
              anonymousSignInButton(),
            ],
          ),
        ),
      ),
    );
  }

  // === UI Components ===

  Widget get topSpace => const SizedBox(height: 20);
  Widget get smallSpace => const SizedBox(height: 20);
  Widget get bottomSpace => const SizedBox(height: 100);

  Widget get loginImage {
    return SizedBox(
      width: 300,
      height: 200,
      child: Image.asset("assets/login.jpg"),
    );
  }

  Text appTitle(TextTheme textTheme) {
    return Text(
      "MP WATER REMINDER",
      textAlign: TextAlign.center,
      style: textTheme.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF19A7CE),
      ),
    );
  }

  Widget get appSubtitle {
    return const Text(
      "Remind you to drink water on time",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Color(0xFF19A7CE)),
    );
  }

  Widget googleSignInButton() {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF146C94),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: handleGoogleSignIn,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/google.jpg', height: 20, width: 20),
            const SizedBox(width: 8),
            const Text(
              "Sign in with Google",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget anonymousSignInButton() {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF6F1F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () async {
          try {
            await auth.signInAnonymously();
          } catch (error) {
            print("Anonymous sign in failed: $error");
          }
        },
        child: const Text(
          "Anonymous sign in",
          style: TextStyle(color: Color(0xFF146C94), fontSize: 16),
        ),
      ),
    );
  }

  void handleGoogleSignIn() async {
    try {
      final provider = GoogleAuthProvider();
      await auth.signInWithProvider(provider);
    } catch (error) {
      print("Google sign in failed: $error");
    }
  }
}
