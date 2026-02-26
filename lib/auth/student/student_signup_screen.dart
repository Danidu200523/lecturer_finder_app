import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class StudentSignUpScreen extends StatefulWidget {
  const StudentSignUpScreen({super.key});

  @override
  State<StudentSignUpScreen> createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends State<StudentSignUpScreen> {
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  String? _selectedFaculty;
  String? _selectedDegree;

  final List<String> faculties = [
    "Business Faculty",
    "Computing Faculty",
    "Engineering Faculty",
    "Science Faculty",
  ];

  final List<String> degrees = [
    "Information Systems",
    "Computer Science",
    "Software Engineering",
    "Business Management",
  ];

  // ----- SIGN UP -----
  Future<void> _signUpStudent() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _selectedFaculty == null ||
        _selectedDegree == null) {
      _showError("Please fill all required fields");
      return;
    }

    try {
      setState(() => _loading = true);

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "name": _nameController.text.trim(),
        "faculty": _selectedFaculty,
        "degreeProgram": _selectedDegree,
        "university": _universityController.text.trim(),
        "email": _emailController.text.trim(),
        "role": "student",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Sign up failed");
    } catch (e) {
      _showError("Something went wrong");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  // ------- TEXT FIELD -------
  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
  }) {
    return Column(
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.gray),
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.gray),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.gray),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.gray, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ---- DROPDOWN FIELD ------
  Widget _dropdownField({
    required String hint,
    required IconData icon,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.gray),
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.gray),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.gray),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.blue, width: 1),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ---- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gray),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Student Sign up",
                style: TextStyle(fontSize: 39, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),

              Image.asset("assets/images/student_login.png", height: 210),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardbg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.blue),
                ),
                child: Column(
                  children: [
                    _inputField(
                      controller: _nameController,
                      icon: Icons.person,
                      hint: "Name",
                    ),

                    _dropdownField(
                      hint: "Faculty",
                      icon: Icons.business,
                      items: faculties,
                      value: _selectedFaculty,
                      onChanged: (value) {
                        setState(() {
                          _selectedFaculty = value;
                        });
                      },
                    ),

                    _dropdownField(
                      hint: "Degree Program",
                      icon: Icons.school,
                      items: degrees,
                      value: _selectedDegree,
                      onChanged: (value) {
                        setState(() {
                          _selectedDegree = value;
                        });
                      },
                    ),

                    _inputField(
                      controller: _universityController,
                      icon: Icons.apartment,
                      hint: "University",
                    ),

                    _inputField(
                      controller: _emailController,
                      icon: Icons.email,
                      hint: "University Email",
                    ),

                    _inputField(
                      controller: _passwordController,
                      icon: Icons.lock,
                      hint: "Create Password",
                      obscure: true,
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signUpStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
