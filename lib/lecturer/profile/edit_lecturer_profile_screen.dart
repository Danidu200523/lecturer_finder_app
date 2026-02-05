import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lecturer_finder_app/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _facultyController = TextEditingController();
  final _departmentController = TextEditingController();
  final _roomController = TextEditingController();
  final _emailController = TextEditingController();

  File? _image;
  String? _photoUrl;
  bool _loading = true;
  bool _saving = false;

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

    _nameController.text = data['name'] ?? '';
    _facultyController.text = data['faculty'] ?? '';
    _departmentController.text = data['department'] ?? '';
    _roomController.text = data['room'] ?? '';
    _emailController.text = data['email'] ?? '';
    _photoUrl = data['photoUrl'];

    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return _photoUrl;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    await ref.putFile(_image!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    final imageUrl = await _uploadImage();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameController.text.trim(),
      'faculty': _facultyController.text.trim(),
      'department': _departmentController.text.trim(),
      'room': _roomController.text.trim(),
      'email': _emailController.text.trim(),
      'photoUrl': imageUrl,
    });

    setState(() => _saving = false);
    Navigator.pop(context);
  }

  Widget _inputField(TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.edit),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        leading: const BackButton(),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: ClipOval(
                      child: _image != null
                          ? kIsWeb
                                ? Image.network(_image!.path, fit: BoxFit.cover)
                                : Image.file(_image!, fit: BoxFit.cover)
                          : _photoUrl != null && _photoUrl!.isNotEmpty
                          ? Image.network(_photoUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.person, size: 60),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Change Profile Picture",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// FORM BOX
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _inputField(_nameController, Icons.person),
                  _inputField(_facultyController, Icons.business),
                  _inputField(_departmentController, Icons.school),
                  _inputField(_roomController, Icons.location_on),
                  _inputField(_emailController, Icons.email),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
