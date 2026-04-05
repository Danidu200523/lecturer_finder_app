import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SlotBookingScreen extends StatelessWidget {
  final String lecturerId;

  const SlotBookingScreen({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: const BackButton(),
        centerTitle: true,
        title: const Text(
          "Available Slots",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('time_slots')
            .where('lecturerId', isEqualTo: lecturerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No slots available"));
          }

          final slots = snapshot.data!.docs;

          return Column(
            children: [
              const SizedBox(height: 10),

              // 🔥 IMAGE (SAFE)
              Image.asset(
                "assets/images/target.png",
                height: 110,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(), // prevents crash
              ),

              const SizedBox(height: 12),

              _tableHeader(),

              Expanded(
                child: ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final doc = slots[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final isBooked = data['status'] == 'booked';
                    final isMine = data['bookedBy'] ==
                        FirebaseAuth.instance.currentUser!.uid;

                    return _slotRow(
                      context,
                      doc.id,
                      data,
                      isBooked,
                      isMine,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🔥 HEADER
  Widget _tableHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Date", style: TextStyle(fontWeight: FontWeight.w500)),
          Text("Time", style: TextStyle(fontWeight: FontWeight.w500)),
          Text("Status", style: TextStyle(fontWeight: FontWeight.w500)),
          Text("Action", style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 🔥 SLOT ROW (100% SAFE)
  Widget _slotRow(BuildContext context, String id,
      Map<String, dynamic> data, bool isBooked, bool isMine) {

    final date = (data['date'] ?? "").toString();
    final start = (data['startTime'] ?? "").toString();
    final end = (data['endTime'] ?? "").toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date),

          // ✅ SAFE TIME DISPLAY
          Text("$start - $end"),

          Text(isBooked ? "Booked" : "Available"),

          // 🔥 BUTTON STATES
          isMine
              ? ElevatedButton(
                  onPressed: () => _cancelBooking(id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(70, 30),
                  ),
                  child: const Text("Booked"),
                )
              : isBooked
                  ? ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        minimumSize: const Size(70, 30),
                      ),
                      child: const Text("Booked"),
                    )
                  : ElevatedButton(
                      onPressed: () => _showConfirm(context, id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(70, 30),
                      ),
                      child: const Text("Book"),
                    ),
        ],
      ),
    );
  }

  // 🔥 CONFIRM DIALOG
  void _showConfirm(BuildContext context, String slotId) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Booking Confirmed",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              const Icon(Icons.check_circle,
                  size: 60, color: Colors.green),

              const SizedBox(height: 12),

              const Text(
                "Your meeting has been confirmed",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _bookSlot(slotId);
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 BOOK SLOT
  Future<void> _bookSlot(String slotId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('time_slots')
        .doc(slotId)
        .update({
      'status': 'booked',
      'bookedBy': userId,
    });
  }

  // 🔥 CANCEL SLOT
  Future<void> _cancelBooking(String slotId) async {
    await FirebaseFirestore.instance
        .collection('time_slots')
        .doc(slotId)
        .update({
      'status': 'available',
      'bookedBy': null,
    });
  }
}