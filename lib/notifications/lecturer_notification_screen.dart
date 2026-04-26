import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lecturer_finder_app/core/theme/app_colors.dart';

class LecturerNotificationScreen extends StatelessWidget {
  const LecturerNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(color: AppColors.black),
        ),
        iconTheme: const IconThemeData(color: AppColors.black),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(color: AppColors.gray),
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] ?? '';
              final message = data['message'] ?? '';
              final isRead = data['read'] ?? false;
              final timestamp = data['createdAt'];

              return GestureDetector(
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(doc.id)
                      .update({'read': true});
                },

                // LONG PRESS DELETE
                onLongPress: () async {
                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(doc.id)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notification deleted")),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: isRead
                        ? AppColors.white
                        : AppColors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isRead
                          ? AppColors.gray
                          : AppColors.blue,
                      width: 1,
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: AppColors.blue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 📄 TEXT CONTENT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // TITLE + TIME + DOT
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: isRead
                                          ? AppColors.black
                                          : AppColors.blue,
                                    ),
                                  ),
                                ),

                                // EXACT TIME RIGHT SIDE
                                if (timestamp != null)
                                  Text(
                                    _formatExactTime(timestamp.toDate()),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.gray,
                                    ),
                                  ),

                                const SizedBox(width: 6),

                                // UNREAD DOT
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // MESSAGE
                            Text(
                              message,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  //  (HH:mm)
  static String _formatExactTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return "$hour:$min";
  }
}