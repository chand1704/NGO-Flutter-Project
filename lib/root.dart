import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngo_project/Admin/Admin_Dashboard.dart';
import 'package:ngo_project/Home_Page.dart';
import 'package:ngo_project/Sign_In_Page.dart';
import 'package:ngo_project/Volunteer/vol_home.dart';

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return SignInPage();
        }
        final User user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
              return SignInPage();
            }
            final data = roleSnapshot.data!.data() as Map<String, dynamic>;
            final String role = (data['role'] ?? 'user')
                .toString()
                .toLowerCase();
            if (role == 'admin') {
              return const AdminDashboard();
            } else if (role == 'volunteer') {
              return const VolHome();
            } else {
              return const HomePage();
            }
          },
        );
      },
    );
  }
}
