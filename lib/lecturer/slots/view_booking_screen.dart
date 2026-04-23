import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ViewBookingScreen extends StatelessWidget {
  final String bookingId;

  const ViewBookingScreen({super.key, required this.bookingId});

  Future<void> updateStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('time_slots') // ✅ FIXED
        .doc(bookingId)
        .update({
      'status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Booking Details",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('time_slots') // ✅ FIXED
            .doc(bookingId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ✅ SAFETY CHECK
          if (!snapshot.data!.exists) {
            return const Center(child: Text("Booking not found"));
          }

          final data = snapshot.data!;
          final map = data.data() as Map<String, dynamic>;

          final studentId = map['bookedBy'] ?? '';
          final date = map['date'] ?? '';
          final time = "${map['startTime']} - ${map['endTime']}";
          final status = map['status'] ?? '';

          /// 🔥 FETCH STUDENT NAME USING UID
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(studentId)
                .get(),
            builder: (context, userSnap) {
              if (!userSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData =
                  userSnap.data!.data() as Map<String, dynamic>?;

              final studentName = userData?['name'] ?? 'Unknown Student';

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Student", studentName),
                    buildRow("Date", date),
                    buildRow("Time", time),
                    buildRow("Status", status),

                    const SizedBox(height: 40),

                    /// ✅ CONFIRM BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        await updateStatus("confirmed");
                        Navigator.pop(context);
                      },
                      child: const Text("Confirm"),
                    ),

                    const SizedBox(height: 10),

                    /// ❌ CANCEL BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        await updateStatus("cancelled");
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        "$title : $value",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}