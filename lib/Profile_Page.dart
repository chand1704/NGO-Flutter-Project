import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isUpdating = false;
  Future<void> _pickAndUploadImage() async {
    if (_isUpdating) return;
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
      );
      if (image == null) return;
      HapticFeedback.mediumImpact();
      setState(() => _isUpdating = true);
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final bytes = await File(image.path).readAsBytes();
      final String base64Image = base64Encode(bytes);
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImage': base64Image,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated successfully")),
        );
      }
    } catch (e) {
      debugPrint("Image upload error: $e");
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _updateUserData() async {
    if (_isUpdating) return;
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
      });
      if (mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: uid == null
          ? const Center(child: Text("Please login to continue"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return const Center(child: Text("User data not found"));
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final String? profileImage = data['profileImage'];
                final String email = data['email'] ?? 'No Email';
                final String role = data['role'] ?? 'User';
                if (_nameController.text.isEmpty) {
                  _nameController.text = data['name'] ?? "";
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileImageSection(profileImage),
                      const SizedBox(height: 15),
                      Text(
                        data['name'] ?? 'User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Display Role as a Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Personal Information",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildPremiumField(
                              controller: _nameController,
                              label: "Display Name",
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 15),
                            _buildReadOnlyField(
                              label: "Email Address",
                              value: email,
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 15),
                            _buildReadOnlyField(
                              label: "Account Role",
                              value: role,
                              icon: Icons.admin_panel_settings_outlined,
                            ),
                            const SizedBox(height: 30),
                            _buildModernSaveButton(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(String? base64String) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (base64String != null && base64String.isNotEmpty)
                  ? MemoryImage(base64Decode(base64String))
                  : null,
              child: (base64String == null || base64String.isEmpty)
                  ? Icon(Icons.person, size: 70, color: Colors.grey.shade400)
                  : null,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildModernSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateUserData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isUpdating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Save Changes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
