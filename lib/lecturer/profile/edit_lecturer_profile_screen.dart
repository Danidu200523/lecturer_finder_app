import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:lecturer_finder_app/core/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ---------------- CONTROLLERS ----------------
  final _nameController = TextEditingController();
  final _facultyController = TextEditingController();
  final _departmentController = TextEditingController();
  final _roomController = TextEditingController();
  final _emailController = TextEditingController();

  // ---------------- IMAGE STATE ----------------
  File? _image;
  Uint8List? _webImageBytes;
  String? _photoUrl;

  bool _loading = true;
  bool _saving = false;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ---------------- LOAD PROFILE ----------------
  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    _nameController.text = data['name'] ?? '';
    _facultyController.text = data['faculty'] ?? '';
    _departmentController.text = data['department'] ?? '';
    _roomController.text = data['cabinLocation'] ?? '';
    _emailController.text = data['email'] ?? '';
    _photoUrl = data['photoUrl'];

    if (mounted) setState(() => _loading = false);
  }

  // ---------------- PICK IMAGE ----------------
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    if (kIsWeb) {
      _webImageBytes = await picked.readAsBytes();
      _image = null;
    } else {
      _image = File(picked.path);
      _webImageBytes = null;
    }

    setState(() {});
  }

  // ---------------- UPLOAD IMAGE ----------------
  Future<String?> _uploadImage() async {
    if (_image == null && _webImageBytes == null) return _photoUrl;

    final ref = FirebaseStorage.instance.ref('profile_images/$uid.jpg');

    UploadTask task;

    if (kIsWeb) {
      task = ref.putData(
        _webImageBytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    } else {
      task = ref.putFile(_image!);
    }

    final snap = await task;
    return await snap.ref.getDownloadURL();
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> _saveProfile() async {
    try {
      setState(() => _saving = true);

      final imageUrl = await _uploadImage();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'faculty': _facultyController.text.trim(),
        'department': _departmentController.text.trim(),
        'cabinLocation': _roomController.text.trim(),
        'email': _emailController.text.trim(),
        'photoUrl': imageUrl,
      });

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------- UI HELPERS ----------------
  Widget _editRow({
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gray),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const Icon(Icons.edit, size: 18, color: AppColors.gray),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Divider(thickness: 0.9),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: AppColors.black),
        ),
        leading: const BackButton(),
        iconTheme: const IconThemeData(color: AppColors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamed(context, '/lecturer-logout');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -------- PROFILE IMAGE --------
            GestureDetector(
              onTap: _pickImage,
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blue, width: 1),
                    ),
                    child: ClipOval(
                      child: _webImageBytes != null
                          ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                          : _image != null
                          ? Image.file(_image!, fit: BoxFit.cover)
                          : (_photoUrl != null && _photoUrl!.isNotEmpty)
                          ? Image.network(_photoUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.person, size: 60),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Change Profile Picture",
                    style: TextStyle(fontSize: 12, color: AppColors.linkedText),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // -------- FORM BOX WITH DIVIDERS --------
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.blue, width: 1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _editRow(icon: Icons.person, controller: _nameController),
                  _divider(),
                  _editRow(
                    icon: Icons.bar_chart,
                    controller: _facultyController,
                  ),
                  _divider(),
                  _editRow(
                    icon: Icons.school,
                    controller: _departmentController,
                  ),
                  _divider(),
                  _editRow(
                    icon: Icons.location_on,
                    controller: _roomController,
                  ),
                  _divider(),
                  _editRow(icon: Icons.email, controller: _emailController),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _saving
                            ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
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
