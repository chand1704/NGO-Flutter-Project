import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngo_project/root.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> login() async {
    try {
      isLoading.value = true;
      // 1. Sign in with Email and Password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // 2. Fetch User Role from Firestore
      String uid = userCredential.user!.uid;
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        String role = userDoc.get('role');
        // 3. Redirect based on role
        if (role == "Admin") {
          Get.offAll(() => Root()); // Replace with your Admin Page
        } else {
          Get.offAll(() => Root()); // Replace with your User Page
        }
      } else {
        Get.snackbar("Error", "User data not found in database.");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "An error occurred");
    } finally {
      isLoading.value = false;
    }
  }
}
