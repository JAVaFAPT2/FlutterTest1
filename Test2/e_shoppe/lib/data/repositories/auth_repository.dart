import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User> _buildUser(fb.User u) async {
    Map<String, dynamic>? data;
    try {
      final doc = await _firestore.collection('profiles').doc(u.uid).get();
      data = doc.data();
    } on FirebaseException catch (e) {
      // If the client is offline or the doc isn't cached yet, fall back to
      // an empty map so login still succeeds.
      if (e.code == 'unavailable') {
        try {
          final doc = await _firestore
              .collection('profiles')
              .doc(u.uid)
              .get(const GetOptions(source: Source.cache));
          data = doc.data();
        } catch (_) {
          data = null;
        }
      } else {
        rethrow;
      }
    }
    return User(
      id: u.uid,
      email: u.email ?? '',
      name: u.displayName ?? '',
      address: data?['address'] as String?,
      phone: data?['phone'] as String?,
    );
  }

  Future<User> currentUser() async {
    final u = _auth.currentUser;
    if (u == null) return User.empty();
    return _buildUser(u);
  }

  Future<User> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return _buildUser(cred.user!);
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user!.updateDisplayName(name);
    return _buildUser(cred.user!);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<User?> updateProfile(
      {String? name, String? address, String? phone}) async {
    final u = _auth.currentUser;
    if (u == null) return null;

    if (name != null && name.isNotEmpty) {
      await u.updateDisplayName(name);
    }

    if (address != null || phone != null) {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(u.uid)
          .set({'address': address, 'phone': phone}, SetOptions(merge: true));
    }

    return _buildUser(u);
  }
}
