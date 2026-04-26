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

                    final status = data['status'] ?? '';
                    final isBooked = status == 'booked';
                    final isCancelled = status == 'cancelled';
                    final isMine = data['bookedBy'] == userId;

                    return _slotRow(
                      context,
                      doc.id,
                      data,
                      status,
                      isBooked,
                      isCancelled,
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
      Map<String, dynamic> data, String status,
      bool isBooked, bool isCancelled, bool isMine) {

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

          Text(
            status == 'available'
                ? "Available"
                : status == 'booked'
                    ? "Booked"
                    : status == 'cancelled'
                        ? "Cancelled"
                        : "",
            style: TextStyle(
              color: status == 'available'
                  ? AppColors.green
                  : status == 'booked'
                      ? AppColors.blue
                      : status == 'cancelled'
                          ? Colors.red
                          : Colors.black,
            ),
          ),

          isCancelled
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Cancelled",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : isMine
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
  if (e is FirebaseException) {
    return e.message ?? "Something went wrong";
  }

  String message = e.toString();

  if (message.contains("Exception:")) {
    message = message.replaceAll("Exception:", "").trim();
  }

  if (message.contains("Dart exception")) {
    return "Something went wrong. Please try again.";
  }

  return message;
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Icon(Icons.check_circle,
                  size: 60, color: AppColors.green),
              const SizedBox(height: 12),
              const Text("Do you want to book this slot?"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: AppColors.blue)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await _bookSlot(slotId);
                      } catch (e) {
                        _showErrorDialog(context, _cleanErrorMessage(e));
                      }
                    },
                    child: const Text("Confirm", style: TextStyle(color: AppColors.blue)),
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

  await FirebaseFirestore.instance.runTransaction((transaction) async {

    final userDoc = await transaction.get(userRef);
    final alreadyBooked = userDoc.data()?['bookedSlotId'];

    if (alreadyBooked != null && alreadyBooked != "") {

      final oldSlotRef = FirebaseFirestore.instance
          .collection('time_slots')
          .doc(alreadyBooked);

      final oldSlotDoc = await transaction.get(oldSlotRef);
      final oldStatus = oldSlotDoc.data()?['status'];

      if (oldStatus == 'booked' || oldStatus == 'confirmed') {
        throw Exception("You have already booked a slot");
      }
    }

    
    final studentName = userDoc.data()?['name'] ?? "Student";

    final slotDoc = await transaction.get(slotRef);
    final lecturerId = slotDoc.data()?['lecturerId'];

    transaction.update(slotRef, {
      'status': 'booked',
      'bookedBy': userId,
    });

    transaction.set(userRef, {
      'bookedSlotId': slotId,
    }, SetOptions(merge: true));

    
    if (lecturerId != null) {
      final notificationRef =
          FirebaseFirestore.instance.collection('notifications').doc();

      transaction.set(notificationRef, {
        'title': 'New Booking',
        'message': '$studentName booked your slot', 
        'receiverId': lecturerId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  });
}
 Future<void> _cancelBooking(BuildContext context, String slotId) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  final userRef =
      FirebaseFirestore.instance.collection('users').doc(userId);
  final slotRef =
      FirebaseFirestore.instance.collection('time_slots').doc(slotId);

  await FirebaseFirestore.instance.runTransaction((transaction) async {

    final userDoc = await transaction.get(userRef);
    final studentName = userDoc.data()?['name'] ?? "Student";

    final slotDoc = await transaction.get(slotRef);
    final lecturerId = slotDoc.data()?['lecturerId'];

    transaction.update(slotRef, {
      'status': 'available',
      'bookedBy': null,
    });

    transaction.update(userRef, {
      'bookedSlotId': null,
    });

    
    if (lecturerId != null) {
      final notificationRef =
          FirebaseFirestore.instance.collection('notifications').doc();

      transaction.set(notificationRef, {
        'title': 'Booking Cancelled',
        'message': '$studentName cancelled the booking', 
        'receiverId': lecturerId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  });

  // ✅ YOUR POPUP (UNCHANGED)
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Icon(
              Icons.cancel,
              color: AppColors.red,
              size: 60,
            ),

            const SizedBox(height: 15),

            const Text(
              "Cancelled",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Your booking has been cancelled successfully.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    ),
  );
}
}