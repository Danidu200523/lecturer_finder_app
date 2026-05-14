import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditStudentProfileScreen extends StatefulWidget {
  const EditStudentProfileScreen({super.key});

  @override
  State<EditStudentProfileScreen> createState() =>
      _EditStudentProfileScreenState();
}

class _EditStudentProfileScreenState extends State<EditStudentProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final facultyController = TextEditingController();
  final courseController = TextEditingController();
  final universityController = TextEditingController();
  final emailController = TextEditingController();
  String photoUrl = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> _changeProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      File file = File(image.path);

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      // STORAGE PATH
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("${user.uid}.jpg");

      // UPLOAD IMAGE
      await ref.putFile(file);

      // GET DOWNLOAD URL
      final imageUrl = await ref.getDownloadURL();

      // UPDATE FIRESTORE
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {"photoUrl": imageUrl},
      );

      setState(() {
        photoUrl = imageUrl;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile picture updated")));
    } catch (e) {
      print(e);
    }
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
      photoUrl = data['photoUrl'] ?? '';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

            CircleAvatar(
              radius: 45,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : const AssetImage("assets/profile.jpg") as ImageProvider,
            ),

            const SizedBox(height: 10),

            Text(
              nameController.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 5),

            GestureDetector(
              onTap: _changeProfilePicture,
              child: const Text(
                "Change Profile Picture",
                style: TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),

          const Icon(Icons.edit, size: 18, color: AppColors.gray),
        ],
      ),
    );
  }
}
