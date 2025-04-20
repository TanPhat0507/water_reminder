import 'package:flutter/material.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  void initState() {
    super.initState();
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
              smallSpace,
              appTitle(textTheme),
              appSubtitle,
              signupImage,
              smallSpace,
              usernameField(),
              passwordField(),
              repasswordField(),
              smallSpace,
              signupButton(),
              smallSpace,
              signupTextLink(context),
            ],
          ),
        ),
      ),
    );
  }

  // === UI Components ===

  Widget get smallSpace => const SizedBox(height: 20);

  Widget get signupImage {
    return SizedBox(
      width: 150,
      height: 150,
      child: Image.asset("assets/signup.jpg"),
    );
  }

  Text appTitle(TextTheme textTheme) {
    return Text(
      "WELCOME!",
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
      "Create your account",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Color(0xFF19A7CE)),
    );
  }

  Widget usernameField() {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF19A7CE)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            child: Icon(Icons.person_outline, color: Color(0xFF19A7CE)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Username",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget passwordField() {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF19A7CE)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            child: Icon(Icons.lock_outline, color: Color(0xFF19A7CE)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget repasswordField() {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF19A7CE)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            child: Icon(Icons.lock_outline, color: Color(0xFF19A7CE)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Confirm password",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget signupButton() {
    return SizedBox(
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sign up",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget signupTextLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have a account? ",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },

            child: const Text(
              "Log in",
              style: TextStyle(
                color: Color(0xFF146C94),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget signupButton() {
  //   return SizedBox(
  //     width: 250,
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: const Color(0xFFF6F1F1),
  //         elevation: 5,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       ),
  //       // elevation: 5,
  //       onPressed: () {},
  //       child: const Text(
  //         "Sign up",
  //         style: TextStyle(color: Color(0xFF146C94), fontSize: 16),
  //       ),
  //     ),
  //   );
  // }

  // void handleGoogleSignIn() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) return; // Người dùng hủy đăng nhập
  //
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //
  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     await auth.signInWithCredential(credential);
  //   } catch (error) {
  //     print("Google sign in failed: $error");
  //   }
  // }
  //
  // Widget userinfo() {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisSize: MainAxisSize.max,
  //       children: [
  //         Container(
  //           width: 100,
  //           height: 100,
  //           decoration: BoxDecoration(
  //             image: DecorationImage(image: NetworkImage(user!.photoURL!)),
  //           ),
  //         ),
  //         Text(user!.email!),
  //         Text(user!.displayName ?? ""),
  //         ElevatedButton(
  //           onPressed: auth.signOut,
  //           child: const Text("Sign Out"),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF146C94),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(30),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
