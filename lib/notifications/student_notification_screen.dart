import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StudentNotificationScreen extends StatelessWidget {
  const StudentNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("Notifications"),
        centerTitle: true,
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(),

        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final role = userSnapshot.data!.get('role');

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('createdAt', descending: true)
                .snapshots(),

            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text("Error loading notifications"),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No notifications"),
                );
              }

              final allDocs = snapshot.data!.docs;

              // 🔥 IMPORTANT FILTER (FIX)
              final notifications = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;

                return data['receiverId'] == userId ||
                       data['receiverId'] == "ALL" ||
                       data['targetRole'] == role ||
                       data['targetRole'] == "all";
              }).toList();

              if (notifications.isEmpty) {
                return const Center(
                  child: Text("No notifications"),
                );
              }

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final doc = notifications[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final title = data['title'] ?? '';
                  final message = data['message'] ?? '';
                  final isRead = data['read'] ?? false;

                  final timestamp = data['createdAt'] as Timestamp?;
                  final timeText = timestamp != null
                      ? _formatExactTime(timestamp.toDate())
                      : '';

                  return GestureDetector(
                    onTap: () async {
                      if (!isRead) {
                        await doc.reference.update({'read': true}); // 🔥 FIXED
                      }
                    },

                    onLongPress: () {
                      _showDeleteDialog(context, doc);
                    },

                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: isRead
                            ? AppColors.white
                            : AppColors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications,
                                  color: isRead
                                      ? AppColors.gray
                                      : AppColors.blue,
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontWeight: isRead
                                              ? FontWeight.w400
                                              : FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(message),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            timeText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatExactTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  void _showDeleteDialog(BuildContext context, QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Notification"),
        content: const Text("Are you sure you want to delete this?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.blue),
            ),
          ),
          TextButton(
            onPressed: () async {
              await doc.reference.delete();
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}