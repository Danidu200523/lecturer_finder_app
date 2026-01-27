import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> lecturerSignUp({
    required String name,
    required String faculty,
    required String department,
    required String cabinLocation,
    required String email,
    required String password,
  }) async {
    // 1. Create Auth account
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;

    // 2. Save lecturer data to Firestore
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'faculty': faculty,
      'department': department,
      'cabinLocation': cabinLocation,
      'email': email,
      'role': 'lecturer',
      'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
