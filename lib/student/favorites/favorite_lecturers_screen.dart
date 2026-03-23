import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StudentFavoritesScreen extends StatelessWidget {
  const StudentFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String studentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(),
        centerTitle: true,
        title: const Text(
          "My Favorite Lecturers",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.titleText,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('favorites')
              .where('studentId', isEqualTo: studentId)
              .snapshots(),
          builder: (context, favSnapshot) {
            if (favSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!favSnapshot.hasData || favSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/warning_image.png', height: 120),
                    const SizedBox(height: 40),
                    const Text(
                      "Sorry !",
                      style: TextStyle(
                        color: AppColors.subtitleText,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "No Favorites Yet !",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.subtitleText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Once you Favorite a Lecturer,\nyou'll see them here",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.subtitleText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/student-search');
                      },
                      child: const Text(
                        "Add to Favorites",
                        style: TextStyle(
                          color: AppColors.linkedText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final favorites = favSnapshot.data!.docs;

            return Column(
              children: [
                const SizedBox(height: 10),

                Image.asset('assets/images/teacher.png', height: 180),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final favDoc = favorites[index];
                      final lecturerId = favDoc['lecturerId'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(lecturerId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const SizedBox();
                          }

                          final lecturer = userSnapshot.data!;
                          if (!lecturer.exists) return const SizedBox();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.gray.withOpacity(0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage:
                                      (lecturer['photoUrl'] != null &&
                                          lecturer['photoUrl']
                                              .toString()
                                              .isNotEmpty)
                                      ? NetworkImage(lecturer['photoUrl'])
                                      : null,
                                  child:
                                      (lecturer['photoUrl'] == null ||
                                          lecturer['photoUrl']
                                              .toString()
                                              .isEmpty)
                                      ? const Icon(Icons.person)
                                      : null,
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lecturer['name'] ?? "",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        lecturer['department'] ?? "",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.star,
                                    color: AppColors.yellow,
                                  ),
                                  onPressed: () async {
                                    await favDoc.reference.delete();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
