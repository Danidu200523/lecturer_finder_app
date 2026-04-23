import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'edit_student_profile_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          "My Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
       actions: [
  Padding(
    padding: const EdgeInsets.only(right: 16),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EditStudentProfileScreen(),
          ),
        );
      },
      child: const Icon(Icons.edit, color: Colors.black),
    ),
  ),
],
      ),

      
      body: Builder(
        builder: (context) {
          final user = FirebaseAuth.instance.currentUser;

          
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            });
            return const SizedBox();
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("No profile data found"));
              }

              final data = snapshot.data!;

              final name = data['name'] ?? '';
              final faculty = data['faculty'] ?? '';
              final course = data['degreeProgram'] ?? '';
              final university = data['university'] ?? '';
              final email = data['email'] ?? user.email ?? '';
              final profileImage =
                  data.data().toString().contains('profileImage')
                      ? data['profileImage']
                      : '';

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: profileImage != ''
                            ? NetworkImage(profileImage)
                            : null,
                        child: profileImage == ''
                            ? const Icon(Icons.person,
                                size: 40, color: Colors.grey)
                            : null,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
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
                            ProfileItem(icon: Icons.person, text: name),
                            const Divider(),
                            ProfileItem(icon: Icons.apartment, text: faculty),
                            const Divider(),
                            ProfileItem(icon: Icons.book, text: course),
                            const Divider(),
                            ProfileItem(icon: Icons.school, text: university),
                            const Divider(),
                            ProfileItem(icon: Icons.alternate_email, text: email),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/student-favorites');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: AppColors.yellow),
                              SizedBox(width: 10),
                              Text(
                                "My Favorite Lecturers",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                "Log Out",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const ProfileItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}