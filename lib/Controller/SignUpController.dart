import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngo_project/service/auth_service.dart';

class Signupcontroller extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var selectedRole = 'User'.obs;
  final List<String> roles = ['User', 'Volunteer'];
  void setSelectedRole(String? value) {
    if (value != null) {
      selectedRole.value = value;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // ================= EMAIL SIGNUP =================
  Future<void> signup() async {
    try {
      isLoading.value = true;
      final User? user = await _authService.createUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (user == null) {
        Get.snackbar("Error", "Signup failed");
        return;
      }
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': nameController.text.trim(),
        'email': user.email,
        'role': selectedRole.value,
        'profileImage': null,
        'provider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar("Signup Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= GOOGLE SIGNUP =================
  Future<void> googleSignup() async {
    try {
      isLoading.value = true;
      final User? user = await _authService.loginWithGoogle();
      if (user == null) return;
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? 'Helping Hands User',
        'email': user.email,
        'role': selectedRole.value,
        'profileImage': user.photoURL,
        'provider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar("Google Signup Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
