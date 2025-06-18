import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<User> currentUser() async {
    final u = _auth.currentUser;
    if (u == null) return User.empty();
    return User(id: u.uid, email: u.email ?? '', name: u.displayName ?? '');
  }

  Future<User> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final u = cred.user!;
    return User(id: u.uid, email: u.email ?? '', name: u.displayName ?? '');
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user!.updateDisplayName(name);
    final u = cred.user!;
    return User(id: u.uid, email: u.email ?? '', name: name);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<User?> updateProfile({String? name, String? address}) async {
    final u = _auth.currentUser;
    if (u == null) return null;

    if (name != null && name.isNotEmpty) {
      await u.updateDisplayName(name);
    }

    if (address != null) {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(u.uid)
          .set({'address': address}, SetOptions(merge: true));
    }

    return User(
        id: u.uid,
        email: u.email ?? '',
        name: u.displayName ?? '',
        address: address);
  }
}
