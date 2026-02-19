//
// import 'package:flutter/material.dart';
//
// import 'Controller/splashscreenController.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );
//
//     // Fade animation for smooth appearance
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
//
//     // 🔥 CORRECTED: Use easeOutBack for the "pop" effect
//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
//
//     _controller.forward();
//
//     // Trigger navigation
//     SplashController.handleNavigation(context);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         // 1. DYNAMIC GRADIENT BACKGROUND
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Decorative background circles for depth
//             Positioned(
//               top: -50,
//               right: -50,
//               child: CircleAvatar(
//                 radius: 100,
//                 backgroundColor: Colors.white.withOpacity(0.05),
//               ),
//             ),
//
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // 2. ANIMATED LOGO
//                   AnimatedBuilder(
//                     animation: _controller,
//                     builder: (context, child) {
//                       return Transform.scale(
//                         scale: _scaleAnimation.value,
//                         child: Opacity(
//                           opacity: _fadeAnimation.value,
//                           child: Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: Image.asset(
//                               'assets/images/ngo_logo.png',
//                               height: 100,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 30),
//
//                   // 3. TEXT WITH FADE
//                   FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: const Column(
//                       children: [
//                         Text(
//                           "Helping Hands NGO",
//                           style: TextStyle(
//                             fontSize: 30,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             letterSpacing: 1.5,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           "Together We Can Make a Difference",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.white70,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // 4. BOTTOM LOADING INDICATOR
//             Positioned(
//               bottom: 60,
//               left: 0,
//               right: 0,
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: 40,
//                       height: 40,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 3,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Colors.white.withOpacity(0.8),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Loading Impact...",
//                       style: TextStyle(
//                         color: Colors.white54,
//                         fontSize: 12,
//                         letterSpacing: 2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import 'Controller/splashscreenController.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // easeOutBack creates that nice springy pop effect
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    SplashController.handleNavigation(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. FRESH LIGHT BACKGROUND
      backgroundColor: const Color(0xFFF1F8E9), // Light Mint/Sage wash
      body: Stack(
        children: [
          // Subtle decorative background patterns
          Positioned(
            bottom: -100,
            left: -50,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.green.withValues(alpha: 0.05),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2. LOGO WITH SOFT SHADOW
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/ngo_logo.png',
                            height: 110,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // 3. ELEGANT TYPOGRAPHY
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        "Helping Hands NGO",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.green[900], // Dark contrast text
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Together We Can Make a Difference",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. MINIMALIST LOADING
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green[400]!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "STARTING HOPE",
                    style: TextStyle(
                      color: Colors.green[300],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
