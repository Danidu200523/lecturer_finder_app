import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class LecturerLoginScreen extends StatefulWidget {
  const LecturerLoginScreen({super.key});

  @override
  State<LecturerLoginScreen> createState() => _LecturerLoginScreenState();
}

class _LecturerLoginScreenState extends State<LecturerLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.gray),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Title
            const Text(
              "Find My Lecturer",
              style: TextStyle(fontSize: 39, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 32),

            // Image
            Image.asset(
              "assets/images/lecturer_login.png", // use your same image
              height: 210,
            ),

            const SizedBox(height: 30),

            // Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardbg,
                border: Border.all(color: AppColors.blue),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Username / Email
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: "Username",
                      border: InputBorder.none,
                    ),
                  ),

                  const Divider(),

                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "Password",
                      border: InputBorder.none,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isLoading ? null : lecturerLogin,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: AppColors.white,
                            )
                          : const Text(
                              "Log In",
                              style: TextStyle(
                                color: AppColors.whiteText,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Forgot password
                  TextButton(
                    onPressed: forgotPassword,
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: AppColors.titleText),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Signup
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don’t have an account? ",
                  style: TextStyle(color: AppColors.titleText),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/lecturer-signup');
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: AppColors.linkedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 LOGIN FUNCTION
  Future<void> lecturerLogin() async {
    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      // 🔍 Check role
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists || userDoc['role'] != 'lecturer') {
        await FirebaseAuth.instance.signOut();
        throw "Not a lecturer account";
      }

      // ✅ Go to lecturer dashboard
      Navigator.pushReplacementNamed(context, '/lecturer-status');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  // 🔑 FORGOT PASSWORD
  Future<void> forgotPassword() async {
    if (emailController.text.isEmpty) return;

    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text.trim(),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Password reset email sent")));
  }
}
