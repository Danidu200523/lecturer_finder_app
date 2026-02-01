import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTimeSlotScreen extends StatefulWidget {
  const AddTimeSlotScreen({super.key});

  @override
  State<AddTimeSlotScreen> createState() => _AddTimeSlotScreenState();
}

class _AddTimeSlotScreenState extends State<AddTimeSlotScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 12, minute: 30);
  TimeOfDay endTime = const TimeOfDay(hour: 13, minute: 30);

  Future<void> createSlot() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('time_slots').add({
      'lecturerId': uid,
      'date': '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
      'startTime': startTime.format(context),
      'endTime': endTime.format(context),
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Time Slots'),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              title: const Text('Date'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Start Time'),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null) {
                    setState(() => startTime = picked);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('End Time'),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) {
                    setState(() => endTime = picked);
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: createSlot,
              child: const Text('Create Slot'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
