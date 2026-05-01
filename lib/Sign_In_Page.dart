import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Controller/SignInController.dart';
import 'Sign_Up_Page.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});
  final c = Get.put(SignInController());
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. SOFT LIGHT MINT BACKGROUND
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    height: 120,
                    width: 120,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/ngo_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  "Sign in to start making an impact",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 35),
                // 2. LOGIN CARD - HIGH ELEVATION
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: c.emailController,
                          label: "Email Address",
                          hint: "example@gmail.com",
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Email is required";
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        Obx(
                          () => _buildTextField(
                            controller: c.passwordController,
                            label: "Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: !c.isPasswordVisible.value,
                            toggleVisibility: () =>
                                c.isPasswordVisible.toggle(),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return "Password is required";
                              return null;
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: c.isLoading.value
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate())
                                        c.login();
                                    },
                              child: c.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildGoogleButton(),
                const SizedBox(height: 20),
                // 3. SIGN UP LINK - DARK CONTRAST
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 15,
                    ),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: "Sign Up",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.to(() => SignUpPage()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () {
          Get.snackbar(
            "Coming Soon",
            "Google Sign-In functionality will be implemented soon!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white70,
          );
        },
        icon: Image.asset("assets/images/google.png", height: 24),
        label: const Text(
          "Continue with Google",
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFCFD8DC)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  // REUSABLE TEXT FIELD COMPONENT
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[350]),
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF9FBF9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
