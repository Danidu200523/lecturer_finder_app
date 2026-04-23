import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class  EditStudentProfileScreen extends StatefulWidget {
  const EditStudentProfileScreen({super.key});

  @override
  State<EditStudentProfileScreen> createState() => _EditStudentProfileScreenState();
}

class _EditStudentProfileScreenState extends State<EditStudentProfileScreen> {

  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final facultyController = TextEditingController();
  final courseController = TextEditingController();
  final universityController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = doc.data();

    if (data != null) {
      nameController.text = data['name'] ?? '';
      facultyController.text = data['faculty'] ?? '';
      courseController.text = data['degreeProgram'] ?? '';
      universityController.text = data['university'] ?? '';
      emailController.text = data['email'] ?? '';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateProfile() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({
      'name': nameController.text,
      'faculty': facultyController.text,
      'degreeProgram': courseController.text,
      'university': universityController.text,
      'email': emailController.text,
    });

    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: AppColors.black),
  onPressed: () {
    Navigator.pop(context);
  },
),
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

           
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage("assets/profile.jpg"),
            ),

            const SizedBox(height: 10),

            
            Text(
              nameController.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Change Profile Picture",
              style: TextStyle(color: AppColors.blue),
            ),

            const SizedBox(height: 20),

            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardbg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.blue),
              ),
              child: Column(
                children: [
                  buildField(Icons.person, nameController),
                  const Divider(),

                  buildField(Icons.apartment, facultyController),
                  const Divider(),

                  buildField(Icons.book, courseController),
                  const Divider(),

                  buildField(Icons.school, universityController),
                  const Divider(),

                  buildField(Icons.alternate_email, emailController),
                ],
              ),
            ),

            const SizedBox(height: 30),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: updateProfile,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  
  Widget buildField(IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gray),
          const SizedBox(width: 15),

          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),

          const Icon(Icons.edit, size: 18, color: AppColors.gray),
        ],
      ),
    );
  }
}