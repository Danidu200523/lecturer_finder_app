import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lecturer_finder_app/core/theme/app_colors.dart';

class LecturerSignUpScreen extends StatefulWidget {
  const LecturerSignUpScreen({super.key});

  @override
  State<LecturerSignUpScreen> createState() => _LecturerSignUpScreenState();
}

class _LecturerSignUpScreenState extends State<LecturerSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final cabinController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedFaculty;
  String? selectedDepartment;

  final List<String> faculties = [
    'Computing Faculty',
    'Business Faculty',
    'Engineering Faculty',
    'Science Faculty',
  ];

  final List<String> departments = [
    'Computer Science',
    'Information Systems',
    'Software Engineering',
  ];

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.gray),
      border: InputBorder.none,
    );
  }

  Widget _inputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// Title
            const Text(
              'Lecturer Sign Up',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            /// Image
            Image.asset(
              'assets/images/lecturer_signup.png', // use your exact image
              height: 180,
            ),

            const SizedBox(height: 20),

            /// Form Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardbg,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// Name
                    _inputContainer(
                      child: TextFormField(
                        controller: nameController,
                        decoration: _inputDecoration(
                          hint: 'Name',
                          icon: Icons.person,
                        ),
                      ),
                    ),

                    /// Faculty Dropdown
                    _inputContainer(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedFaculty,
                        decoration: _inputDecoration(
                          hint: 'Faculty',
                          icon: Icons.apartment,
                        ),
                        items: faculties
                            .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedFaculty = value);
                        },
                      ),
                    ),

                    /// Department Dropdown
                    _inputContainer(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedDepartment,
                        decoration: _inputDecoration(
                          hint: 'Department',
                          icon: Icons.account_tree,
                        ),
                        items: departments
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedDepartment = value);
                        },
                      ),
                    ),

                    /// Cabin Location
                    _inputContainer(
                      child: TextFormField(
                        controller: cabinController,
                        decoration: _inputDecoration(
                          hint: 'Cabin Location',
                          icon: Icons.location_on,
                        ),
                      ),
                    ),

                    /// University Email
                    _inputContainer(
                      child: TextFormField(
                        controller: emailController,
                        decoration: _inputDecoration(
                          hint: 'University Email',
                          icon: Icons.email,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),

                    /// Password
                    _inputContainer(
                      child: TextFormField(
                        controller: passwordController,
                        decoration: _inputDecoration(
                          hint: 'Create Password',
                          icon: Icons.lock,
                        ),
                        obscureText: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            // 1️⃣ Create user with Firebase Authentication
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .createUserWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                            // 2️⃣ Get user UID
                            String uid = userCredential.user!.uid;

                            // 3️⃣ Save lecturer data to Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({
                                  'name': nameController.text.trim(),
                                  'faculty': selectedFaculty,
                                  'department': selectedDepartment,
                                  'cabinLocation': cabinController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'role': 'lecturer',
                                  'photoUrl': '',
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            // 4️⃣ Navigate after success
                            Navigator.pushReplacementNamed(
                              context,
                              '/lecturer-home',
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },

                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
