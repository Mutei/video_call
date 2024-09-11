import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call/screens/login_screen.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref("App").child("User");

  FirebaseAuth get auth => _auth;

  // Function to sign up with email, password, and user details
  Future<bool> signUpWithEmailAndDetails(String email, String password,
      String firstName, String secondName, String lastName) async {
    try {
      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();

      // Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user details and FCM token in Firebase Realtime Database
      if (userCredential.user != null && token != null) {
        await _ref.child(userCredential.user!.uid).set({
          'Email': email,
          'FirstName': firstName,
          'SecondName': secondName,
          'LastName': lastName,
          'Token': token, // Save FCM token here
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing up: $e');
      return false;
    }
  }

  // Function to sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update FCM token on login
      if (userCredential.user != null) {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _ref.child(userCredential.user!.uid).update({
            'Token': token, // Update FCM token here on login
          });
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  // Function to save user data in Firebase Realtime Database
  Future<void> saveUserDetails(String userId, String firstName,
      String secondName, String lastName) async {
    await _ref.child(userId).set({
      'FirstName': firstName,
      'SecondName': secondName,
      'LastName': lastName,
    });
  }

  Future<void> signOut(BuildContext context) async {
    try {
      String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref("App/User/$userId");

        // Remove the session ID on logout
        await userRef.update({
          "Token": null, // Remove FCM token on logout
        });

        await FirebaseMessaging.instance.deleteToken();
      }

      await _auth.signOut();

      // Ensure SharedPreferences is cleared
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.clear();

      // Navigate to login screen after signing out
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } catch (e) {
      print('Failed to sign out: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
      );
    }
  }
}
