import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===============================
  // LECTURER SIGN UP (EXISTING)
  // ===============================
  Future<void> lecturerSignUp({
    required String name,
    required String faculty,
    required String department,
    required String cabinLocation,
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;

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

  // ===============================
  // LECTURER LOGOUT (BACKEND)
  // ===============================
  Future<void> lecturerLogout() async {
    await _auth.signOut();
  }

  // ===============================
  // GET CURRENT USER (OPTIONAL BUT IMPORTANT)
  // ===============================
  User? get currentUser => _auth.currentUser;
}
