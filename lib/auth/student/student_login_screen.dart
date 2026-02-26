import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  // ---------------- LOGIN FUNCTION ----------------
  Future<void> _loginStudent() async {
    try {
      setState(() => _loading = true);

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // 🔍 Check role in Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw Exception("User data not found");
      }

      final role = doc.data()!['role'];

      if (role != "student") {
        await FirebaseAuth.instance.signOut();
        throw Exception("This account is not a student account");
      }

      //  Navigate
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/student-search',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login failed");
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Student Log In",
                style: TextStyle(fontSize: 39, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),

              // image
              Image.asset("assets/images/student_login.png", height: 210),

              const SizedBox(height: 30),

              // -------- FORM CARD --------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardbg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.blue),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Email Field
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: "Username",
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        hintText: "Password",
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 25),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _loginStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
                            : const Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/student-forgot-password',
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: AppColors.black),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sign Up Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/student-signup');
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
