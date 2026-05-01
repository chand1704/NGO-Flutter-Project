import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Controller/SignUpController.dart';
import 'Sign_In_Page.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final formKey = GlobalKey<FormState>();
  final controller = Get.put(Signupcontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. SOFT LIGHT BACKGROUND (Eco-Fresh Wash)
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  padding: const EdgeInsets.all(15),
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
                const SizedBox(height: 25),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  "Join our community of change-makers",
                  style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                ),
                const SizedBox(height: 30),
                // 2. THE REGISTRATION CARD
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
                    key: formKey,
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: controller.nameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          validator: (v) =>
                              v!.isEmpty ? "Enter your name" : null,
                        ),
                        const SizedBox(height: 18),
                        _buildInputField(
                          controller: controller.emailController,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          validator: (v) =>
                              !v!.contains('@') ? "Enter a valid email" : null,
                        ),
                        const SizedBox(height: 18),
                        // ROLE DROPDOWN
                        Obx(
                          () => DropdownButtonFormField<String>(
                            value: controller.selectedRole.value,
                            decoration: _inputDecoration(
                              "Select Role",
                              Icons.assignment_ind_outlined,
                            ),
                            items: controller.roles.map((String role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (val) => controller.setSelectedRole(val),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // PASSWORD
                        Obx(
                          () => _buildInputField(
                            controller: controller.passwordController,
                            label: "Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: !controller.isPasswordVisible.value,
                            toggleIcon: () =>
                                controller.isPasswordVisible.toggle(),
                            validator: (v) =>
                                v!.length < 6 ? "Minimum 6 characters" : null,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // CONFIRM PASSWORD
                        Obx(
                          () => _buildInputField(
                            label: "Confirm Password",
                            icon: Icons.lock_reset_outlined,
                            isPassword: true,
                            obscureText:
                                !controller.isConfirmPasswordVisible.value,
                            toggleIcon: () =>
                                controller.isConfirmPasswordVisible.toggle(),
                            validator: (v) =>
                                v != controller.passwordController.text
                                ? "Passwords don't match"
                                : null,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // PRIMARY ACTION BUTTON
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
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        controller.signup();
                                      }
                                    },
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "SIGN UP",
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
                const SizedBox(height: 25),
                // 3. GOOGLE SIGNUP (Dark Outline)
                _buildGoogleButton(),
                const SizedBox(height: 25),
                // SIGN IN LINK
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 15,
                    ),
                    children: [
                      const TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: "Sign In",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.to(() => SignInPage()),
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

  Widget _buildInputField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: _inputDecoration(label, icon).copyWith(
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: toggleIcon,
              )
            : null,
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
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
        borderSide: const BorderSide(color: Colors.redAccent),
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
            "Google Sign-Up functionality will be implemented soon!",
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
}
