
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> signUpAdmin({
    required String email,
    required String password,
    required String name,
    required String gymId,
    required String location,
  }) async {
    try {
      final gymDoc = await _firestore.collection('gyms').doc(gymId).get();
      if (gymDoc.exists) return "Gym ID already registered.";

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('gyms').doc(gymId).set({
        'gymId': gymId,
        'adminId': credential.user!.uid,
        'gymName': name,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'name': name,
        'role': 'admin',
        'gymId': gymId,
        'location': location,
          'profileImageUrl': '',
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // UPDATED: Auto-create NOT_PAID transaction on signup
  Future<String?> signUpMember({
    required String email,
    required String password,
    required String name,
    required String gymId,
    required String role,
    required String location,
  }) async {
    try {
      final gymDoc = await _firestore.collection('gyms').doc(gymId).get();
      if (!gymDoc.exists) return "Invalid Gym ID.";

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('members')
          .doc(credential.user!.uid)
          .set({
            'uid': credential.user!.uid,
            'name': name,
            'email': email,
            'role': role,
            'joinDate': FieldValue.serverTimestamp(),
            'membershipStatus': 'not_paid',
            'lastVisit': null,
            'gymId': gymId,
            'profileImageUrl': '',
            'location': location,
          });

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'name': name,
        'role': role,
        'gymId': gymId,
          'profileImageUrl': '',
        'location': location,
      });

      //  NEW: Auto-create NOT_PAID transaction
      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('payments')
          .add({
            'memberId': credential.user!.uid,
            'memberName': name,
            'memberEmail': email,
            'gymId': gymId,
            'planId': '',
            'planName': 'No Plan Selected',
            'amount': 0.0,
            'duration': '',
            'paymentMethodId': '',
            'paymentMethodType': '',
            'paymentMethodLabel': '',
            'accountTitle': '',
            'accountNumber': '',
            'screenshotUrl': '',
            'status': 'not_paid',
            'createdAt': FieldValue.serverTimestamp(),
            'submittedAt': null,
            'approvedAt': null,
            'rejectedAt': null,
            'reviewedBy': '',
            'rejectionReason': '',
          });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async => await _auth.signOut();
  Future<void> resetPassword(String email) async =>
      await _auth.sendPasswordResetEmail(email: email);
}
