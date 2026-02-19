import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngo_project/Sign_In_Page.dart';
import 'package:ngo_project/Sign_Up_Page.dart';
import 'package:ngo_project/Splash_Screen.dart';
import 'package:ngo_project/root.dart';

import 'Donate_Page.dart';
import 'Profile_Page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAN61HYbVQgUw39PLTJglMkpmlOlQanpfw",
        authDomain: "ngo-project-528c6.firebaseapp.com",
        projectId: "ngo-project-528c6",
        storageBucket: "ngo-project-528c6.firebasestorage.app",
        messagingSenderId: "485491134296",
        appId: "1:485491134296:web:5e4ec7d31ccaf0633d9f2d",
        measurementId: "G-WBEM9MYNFY",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NGO APP",
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/signup': (context) => SignUpPage(),
        '/signin': (context) => SignInPage(),
        // '/home': (context) => HomePage(),
        '/home': (context) => Root(),
        '/profile': (context) => ProfilePage(),
        '/donate': (context) => DonatePage(),
        // home: const MyHomePage(),
      },
    );
  }
}
