import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lecturer_finder_app/core/theme/app_colors.dart';

class LecturerStatusScreen extends StatefulWidget {
  const LecturerStatusScreen({super.key});

  @override
  State<LecturerStatusScreen> createState() => _LecturerStatusScreenState();
}

class _LecturerStatusScreenState extends State<LecturerStatusScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  /// Update status directly to Firestore
  Future<void> updateStatus(String status) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final String name = data['name'] ?? 'Lecturer';
          final String faculty = data['faculty'] ?? '';
          final String department = data['department'] ?? '';
          final String cabin = data['cabinLocation'] ?? '';
          final String status = data['status'] ?? 'available';
          final String photoUrl =
              data['photoUrl'] ?? 'https://via.placeholder.com/150';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// Profile image
                CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(photoUrl),
                ),

                const SizedBox(height: 12),

                /// Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  department,
                  style: const TextStyle(color: AppColors.titleText),
                ),
                Text(
                  faculty,
                  style: const TextStyle(color: AppColors.subtitleText),
                ),
                Text(
                  cabin,
                  style: const TextStyle(color: AppColors.subtitleText),
                ),

                const SizedBox(height: 28),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Current Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 14),

                /// STATUS BUTTONS
                statusButton(
                  label: 'Available at Cabin',
                  value: 'available',
                  currentStatus: status,
                  color: AppColors.green,
                  icon: Icons.check_circle,
                ),

                statusButton(
                  label: 'Temporary Away',
                  value: 'away',
                  currentStatus: status,
                  color: AppColors.yellow,
                  icon: Icons.hourglass_empty,
                ),

                statusButton(
                  label: 'On Leave',
                  value: 'leave',
                  currentStatus: status,
                  color: AppColors.red,
                  icon: Icons.cancel,
                ),

                const SizedBox(height: 20),

                /// Add slot
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/manage-slots');
                  },
                  icon: const Icon(Icons.add, color: AppColors.black),
                  label: const Text(
                    'Add Meeting Slot',
                    style: TextStyle(color: AppColors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.blue, width: 1),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-profile');
                  },
                  child: const Text(
                    'Edit profile',
                    style: TextStyle(color: AppColors.linkedText),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Reusable status button with outline for selected state
  Widget statusButton({
    required String label,
    required String value,
    required String currentStatus,
    required Color color,
    required IconData icon,
  }) {
    final bool isSelected = currentStatus == value;

    return GestureDetector(
      onTap: () => updateStatus(value),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: isSelected ? 3 : 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
