import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createLecturer({
    required String uid,
    required String name,
    required String email,
    required String faculty,
    required String department,
    required String cabinLocation,
  }) async {
    await _db.collection('users').doc(uid).set({
      'role': 'lecturer',
      'name': name,
      'email': email,
      'faculty': faculty,
      'department': department,
      'cabinLocation': cabinLocation,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}