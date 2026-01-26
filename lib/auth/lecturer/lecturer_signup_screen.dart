import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class LecturerSignupScreen extends StatefulWidget {
  const LecturerSignupScreen({super.key});

  @override
  State<LecturerSignupScreen> createState() => _LecturerSignupScreenState();
}

class _LecturerSignupScreenState extends State<LecturerSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final facultyCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final cabinCtrl = TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool loading = false;

  Future<void> _signupLecturer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = await _authService.signUp(
        emailCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );

      if (user != null) {
        await _userService.createLecturer(
          uid: user.uid,
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          faculty: facultyCtrl.text.trim(),
          department: departmentCtrl.text.trim(),
          cabinLocation: cabinCtrl.text.trim(),
        );

        // Navigate to lecturer dashboard later
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lecturer account created')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecturer Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
              ),
              TextFormField(
                controller: facultyCtrl,
                decoration: const InputDecoration(labelText: 'Faculty'),
              ),
              TextFormField(
                controller: departmentCtrl,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextFormField(
                controller: cabinCtrl,
                decoration: const InputDecoration(labelText: 'Cabin Location'),
              ),
              const SizedBox(height: 20),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signupLecturer,
                      child: const Text('Create Account'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
