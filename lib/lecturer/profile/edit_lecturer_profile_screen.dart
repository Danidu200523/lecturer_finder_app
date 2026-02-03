import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lecturer_finder_app/core/theme/app_colors.dart';

class LecturerEditProfileScreen extends StatefulWidget {
  const LecturerEditProfileScreen({super.key});

  @override
  State<LecturerEditProfileScreen> createState() =>
      _LecturerEditProfileScreenState();
}

class _LecturerEditProfileScreenState extends State<LecturerEditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _cabinCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String? photoUrl;
  File? pickedImage;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data()!;
    setState(() {
      _nameCtrl.text = data['name'] ?? '';
      _facultyCtrl.text = data['faculty'] ?? '';
      _deptCtrl.text = data['department'] ?? '';
      _cabinCtrl.text = data['cabin'] ?? '';
      _emailCtrl.text = data['email'] ?? '';
      photoUrl = data['photoUrl'];
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage() async {
    if (pickedImage == null) return photoUrl;

    final ref = FirebaseStorage.instance.ref('profile_photos/$uid.jpg');

    await ref.putFile(pickedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    final imageUrl = await _uploadImage();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameCtrl.text.trim(),
      'faculty': _facultyCtrl.text.trim(),
      'department': _deptCtrl.text.trim(),
      'cabin': _cabinCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'photoUrl': imageUrl,
    });

    Navigator.pop(context);
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.edit),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        leading: const BackButton(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// PROFILE IMAGE
              GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: pickedImage != null
                              ? FileImage(pickedImage!)
                              : photoUrl != null
                              ? NetworkImage(photoUrl!)
                              : const AssetImage(
                                      'assets/images/profile_placeholder.png',
                                    )
                                    as ImageProvider,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Change Profile Picture",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.linkedText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// FORM CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBlue),
                ),
                child: Column(
                  children: [
                    _inputField(controller: _nameCtrl, icon: Icons.person),
                    _inputField(
                      controller: _facultyCtrl,
                      icon: Icons.apartment,
                    ),
                    _inputField(controller: _deptCtrl, icon: Icons.menu_book),
                    _inputField(
                      controller: _cabinCtrl,
                      icon: Icons.location_on,
                    ),
                    _inputField(controller: _emailCtrl, icon: Icons.email),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(color: AppColors.whiteText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
