import 'package:chatup/views/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String?> getUsername() async {
    try {
      // Reference to the 'Users' collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(getCurrentUser()!.uid)
          .get();

      // Check if the document exists and retrieve the username
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;

        return data['Username'];
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

//Sign In
  Future<UserCredential> SignInWithEmailPassword(
      String Email, String Password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: Email, password: Password);

          

      // _firestore.collection("Users").doc(userCredential.user!.uid).set({
      //   'uid': userCredential.user!.uid,
      //   'email': userCredential.user!.email
      // });
      return userCredential;
    } catch (e) {
      throw Exception(e);
    }
    //
    // on FirebaseAuthException catch (e) {
    //   throw Exception(e.code);
  }

  //Sign up

  Future<UserCredential> SignUpWithEmailPassword(
      String email, String password, String Username) async {
    try {
      // Check if the username is unique
      bool isUnique = await isUsernameUnique(Username);
      if (!isUnique) {
        throw Exception(
            "Username already exists. Please choose a different username.");
      }

      // Create a new user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set user details in Firestore
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'Username': Username,
        'avatarURL': ""
      });

      // Print success message for debugging purposes

      return userCredential;
    } catch (e) {
      print("Error: $e"); // Print the error for debugging purposes
      throw Exception(e);
    }
  }

  //Sign out
  Future<void> SignOutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw (e);
    }
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      // Query Firestore to check if the username already exists
      final querySnapshot = await _firestore
          .collection('Users')
          .where('Username', isEqualTo: username)
          .get();

      // If the query returns any documents, the username is not unique
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print("Error: $e"); // Print the error for debugging purposes
      throw Exception(e);
    }
  }
}
