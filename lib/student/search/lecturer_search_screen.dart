import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StudentSearchScreen extends StatefulWidget {
  const StudentSearchScreen({super.key});

  @override
  State<StudentSearchScreen> createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  bool _isPressed = false;

  final String studentId = FirebaseAuth.instance.currentUser!.uid;

  /// TOGGLE FAVORITE
  Future<void> toggleFavorite(String lecturerId, bool isFav) async {
    final favRef = FirebaseFirestore.instance.collection('favorites');

    if (isFav) {
      final snapshot = await favRef
          .where('studentId', isEqualTo: studentId)
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } else {
      await favRef.add({
        'studentId': studentId,
        'lecturerId': lecturerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// CHECK IF FAVORITE
  Stream<bool> isFavorite(String lecturerId) {
    return FirebaseFirestore.instance
        .collection('favorites')
        .where('studentId', isEqualTo: studentId)
        .where('lecturerId', isEqualTo: lecturerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.titleText),
            onPressed: () {
              Navigator.pushNamed(context, '/student-profile');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              const Text(
                "Search for Lecturers",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 20),

              /// SEARCH BAR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.gray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Search",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  child: Material(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTapDown: (_) {
                        setState(() => _isPressed = true);
                      },
                      onTapUp: (_) {
                        setState(() => _isPressed = false);
                        Navigator.pushNamed(context, '/student-favorites');
                      },
                      onTapCancel: () {
                        setState(() => _isPressed = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.blue),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Favorites",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.star, color: AppColors.yellow, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// LECTURER LIST
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'lecturer')
                      .snapshots(),
                  builder: (context, snapshot) {
                    /// 🔥 FIX 1 — HANDLE WAITING STATE
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    /// 🔥 FIX 2 — HANDLE ERROR
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error loading lecturers",
                          style: TextStyle(color: AppColors.red),
                        ),
                      );
                    }

                    /// 🔥 FIX 3 — HANDLE EMPTY
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No lecturers found"));
                    }

                    final lecturers = snapshot.data!.docs.where((doc) {
                      final name = (doc['name'] ?? "").toString().toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                    return ListView.builder(
                      itemCount: lecturers.length,
                      itemBuilder: (context, index) {
                        final doc = lecturers[index];
                        final lecturerId = doc.id;

                        return StreamBuilder<bool>(
                          stream: isFavorite(lecturerId),
                          builder: (context, favSnapshot) {
                            final isFav = favSnapshot.data ?? false;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.gray.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        (doc['photoUrl'] != null &&
                                            doc['photoUrl']
                                                .toString()
                                                .isNotEmpty)
                                        ? NetworkImage(doc['photoUrl'])
                                        : null,
                                    child:
                                        (doc['photoUrl'] == null ||
                                            doc['photoUrl'].toString().isEmpty)
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc['name'] ?? "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          doc['department'] ?? "",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFav ? Icons.star : Icons.star_border,
                                      color: isFav
                                          ? AppColors.yellow
                                          : AppColors.gray,
                                    ),
                                    onPressed: () {
                                      toggleFavorite(lecturerId, isFav);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
