import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lecturer_finder_app/core/theme/app_colors.dart';

class SlotManagementScreen extends StatefulWidget {
  const SlotManagementScreen({super.key});

  @override
  State<SlotManagementScreen> createState() => _SlotManagementScreenState();
}

class _SlotManagementScreenState extends State<SlotManagementScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    /// WAIT until FirebaseAuth is ready
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final lecturerId = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Time Slots"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/add-slot');
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('time_slots')
            .where('lecturerId', isEqualTo: lecturerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No time slots created",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final slots = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 20),

              Center(
                child: Image.asset(
                  'assets/images/calendar.png',
                  width: 340,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              /// HEADER ROW
              _tableRow(
                isHeader: true,
                date: "Date",
                time: "Time",
                status: "Status",
                action: "Action",
              ),

              const SizedBox(height: 8),

              /// DATA ROWS
              ...slots.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final date = data['date'] ?? '';
                final start = data['startTime'] ?? '';
                final end = data['endTime'] ?? '';
                final status = data['status'] ?? '';

                return _tableRow(
                  date: date,
                  time: "$start - $end",
                  status: status,
                  isBooked: status == 'booked',
                  onDelete: () async {
                    await FirebaseFirestore.instance
                        .collection('time_slots')
                        .doc(doc.id)
                        .delete();
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  /// ROW WIDGET
  Widget _tableRow({
    required String date,
    required String time,
    required String status,
    String? action,
    bool isHeader = false,
    bool isBooked = false,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          /// DATE
          Expanded(
            flex: 2,
            child: Text(
              date,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          /// TIME
          Expanded(
            flex: 2,
            child: isHeader
                ? Text(
                    'Time',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time.split('-').first.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time.split('-').last.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
          ),

          /// STATUS
          Expanded(
            flex: 2,
            child: Text(
              status,
              style: TextStyle(
                color: status == 'available'
                    ? Colors.green
                    : status == 'booked'
                    ? Colors.blue
                    : Colors.black,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          /// ACTION
          SizedBox(
            width: 90, // 👈 FIXED WIDTH PREVENTS OVERFLOW
            child: isHeader
                ? const Text(
                    'Action',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                : isBooked
                ? SizedBox(
                    width: 70,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        "View",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min, // 👈 CRITICAL
                    children: [
                      const SizedBox(width: 30),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
