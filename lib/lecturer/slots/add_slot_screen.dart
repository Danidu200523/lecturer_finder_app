import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lecturer_finder_app/core/theme/app_colors.dart';

class AddTimeSlotScreen extends StatefulWidget {
  const AddTimeSlotScreen({super.key});

  @override
  State<AddTimeSlotScreen> createState() => _AddTimeSlotScreenState();
}

class _AddTimeSlotScreenState extends State<AddTimeSlotScreen> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  /// SELECT BOX UI (UNCHANGED)
  Widget selectBox({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool selected = false,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.darkBlue : Colors.grey.shade300,
            width: 2,
          ),
          color: selected ? AppColors.blue.withOpacity(0.05) : AppColors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? AppColors.darkBlue : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.darkBlue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CREATE SLOT LOGIC (FIXED & SAFE)
  Future<void> createSlot() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    await FirebaseFirestore.instance.collection('time_slots').add({
      'lecturerId': user.uid,
      'date':
          '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
      'startTime': startTime!.format(context),
      'endTime': endTime!.format(context),
      'status': 'available',
      'bookedBy': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Time Slots'),
        leading: const BackButton(),
      ),

      /// BODY (STRUCTURE FIXED – UI SAME)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// IMAGE (YOUR IMAGE ONLY)
              Center(
                child: Image.asset(
                  'assets/images/slot.png',
                  width: 240,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              /// DATE
              selectBox(
                label: "Date",
                value: selectedDate == null
                    ? "Select date"
                    : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                selected: selectedDate != null,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),

              /// START TIME
              selectBox(
                label: "Start Time",
                value: startTime == null
                    ? "Select start time"
                    : startTime!.format(context),
                selected: startTime != null,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => startTime = picked);
                  }
                },
              ),

              /// END TIME
              selectBox(
                label: "End Time",
                value: endTime == null
                    ? "Select end time"
                    : endTime!.format(context),
                selected: endTime != null,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => endTime = picked);
                  }
                },
              ),

              const SizedBox(height: 30),

              /// CREATE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: createSlot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Create Slot",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// CANCEL BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.titleText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
