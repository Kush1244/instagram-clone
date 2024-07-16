import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:instagram_clone/resources/storage_method.dart';
import 'package:instagram_clone/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // signup user

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('user').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  Future<String> signupUser(
      {required String email,
      required String password,
      required String username,
      required String bio,
      required Uint8List file}) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String photoUrl = await StorageMethod()
            .uploadImageToStorage('profilePics', file, false);
        // Add user to our database
        print(cred.user!.uid);
        model.User user = model.User(
            username: username,
            uid: cred.user!.uid,
            photoUrl: photoUrl,
            email: email,
            bio: bio,
            followers: [],
            following: []);
        await _firestore.collection('user').doc(cred.user!.uid).set(
              user.toJson(),
            );
        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = "Invalid Email";
      } else if (err.code == 'weak-password') {
        res = "password is Weak";
      }
      res = err.toString();
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // logging user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        res = "Please enter all the fields";
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  Future<void> SignOut() async {
    _auth.signOut();
  }
}
