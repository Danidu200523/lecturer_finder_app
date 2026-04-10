import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SlotBookingScreen extends StatelessWidget {
  final String lecturerId;

  const SlotBookingScreen({super.key, required this.lecturerId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
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
              Image.asset(
                "assets/images/target.png",
                height: 130,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(),
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
                    final isMine = data['bookedBy'] == userId;

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

  Widget _tableHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.darkBlue),
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

  Widget _slotRow(BuildContext context, String id,
      Map<String, dynamic> data, bool isBooked, bool isMine) {
    final date = (data['date'] ?? "").toString();
    final start = (data['startTime'] ?? "").toString();
    final end = (data['endTime'] ?? "").toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date),
          Text("$start - $end"),
          Text(isBooked ? "Booked" : "Available"),
          isMine
              ? ElevatedButton(
                  onPressed: () => _cancelBooking(context, id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(70, 30),
                  ),
                  child: const Text("Booked"),
                )
              : isBooked
                  ? ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(70, 30),
                      ),
                      child: const Text("Booked"),
                    )
                  : ElevatedButton(
                      onPressed: () => _showConfirm(context, id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(70, 30),
                      ),
                      child: const Text("Book"),
                    ),
        ],
      ),
    );
  }

 
  String _cleanErrorMessage(dynamic e) {
    String message = e.toString();

    if (message.contains("Exception:")) {
      message = message.split("Exception:").last;
    }

    if (message.contains("Error:")) {
      message = message.split("Error:").last;
    }

    if (message.contains("]")) {
      message = message.split("]").last;
    }

    return message.trim();
  }

  void _showErrorDialog(BuildContext context, String message) {
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
              const Icon(Icons.error, color: AppColors.red, size: 60),
              const SizedBox(height: 15),
              const Text(
                "Booking Error",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        ),
      ),
    );
  }

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
                "Confirm Booking",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Icon(Icons.check_circle,
                  size: 60, color: AppColors.green),
              const SizedBox(height: 12),
              const Text(
                "Do you want to book this slot?",
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);

                      try {
                        await _bookSlot(slotId);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Slot booked successfully")),
                        );
                      } catch (e) {
                        _showErrorDialog(
                            context, _cleanErrorMessage(e)); 
                      }
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

  Future<void> _bookSlot(String slotId) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  final userRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

  final slotRef =
      FirebaseFirestore.instance.collection('time_slots').doc(slotId);

 
  final userDoc = await userRef.get();
  final slotDoc = await slotRef.get();

  final userData = userDoc.data() as Map<String, dynamic>? ?? {};
  final slotData = slotDoc.data() as Map<String, dynamic>;

  if (userData['bookedSlotId'] != null) {
    throw "You already have a booking.\nCancel it before booking another.";
  }

  if (slotData['status'] == 'booked') {
    throw "This slot is already booked.";
  }

  
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    transaction.update(slotRef, {
      'status': 'booked',
      'bookedBy': userId,
    });

    transaction.set(userRef, {
      'bookedSlotId': slotId,
    }, SetOptions(merge: true));
  });
}

  Future<void> _cancelBooking(BuildContext context, String slotId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    final slotRef =
        FirebaseFirestore.instance.collection('time_slots').doc(slotId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(slotRef, {
          'status': 'available',
          'bookedBy': null,
        });

        transaction.update(userRef, {
          'bookedSlotId': null,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking cancelled")),
      );
    } catch (e) {
      _showErrorDialog(context, _cleanErrorMessage(e));
    }
  }
}