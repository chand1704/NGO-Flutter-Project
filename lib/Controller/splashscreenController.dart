import 'dart:async';

import 'package:flutter/material.dart';

import '../service/auth_service.dart';

class SplashController {
  // Logic to determine where to go next
  static void handleNavigation(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      if (!context.mounted) return;

      AuthService().authStateChanges.listen((user) {
        if (!context.mounted) return;

        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/signin');
        }
      });
    });
  }
}
