import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Admin_UserDetails.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});
  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String searchQuery = "";
  String activeFilter = "All";
  Future<void> _updateRole(String uid, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': newRole,
      });
      Get.snackbar(
        "Success",
        "Role updated to ${newRole.toUpperCase()}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Update failed",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showRoleDialog(String uid, String currentRole, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Update Role for $name",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _roleTile(uid, 'Admin', Colors.red, currentRole),
            _roleTile(uid, 'Volunteer', Colors.blue, currentRole),
            _roleTile(uid, 'User', Colors.green, currentRole),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _roleTile(String uid, String role, Color color, String current) {
    return ListTile(
      leading: Icon(Icons.shield_outlined, color: color),
      title: Text(
        role.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      trailing: current == role
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        _updateRole(uid, role);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildDynamicInsightHeader(),
          _buildSearchAndFilter(),
          Expanded(child: _buildDynamicUserList()),
        ],
      ),
    );
  }

  Widget _buildDynamicInsightHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        var docs = snapshot.data!.docs;
        int total = docs.length;
        int admin = docs.where((d) => d['role'] == 'Admin').length;
        int volunteer = docs.where((d) => d['role'] == 'Volunteer').length;
        int user = docs.where((d) => d['role'] == 'User').length;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                height: 110,
                width: 110,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 32,
                    sections: [
                      PieChartSectionData(
                        value: admin.toDouble(),
                        color: Colors.redAccent,
                        radius: 8,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: volunteer.toDouble(),
                        color: Colors.blueAccent,
                        radius: 8,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: user.toDouble(),
                        color: Colors.greenAccent[700],
                        radius: 8,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Total Users: $total",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _statRow("Admins", admin, Colors.redAccent),
                    _statRow("Volunteers", volunteer, Colors.blueAccent),
                    _statRow("Basic Users", user, Colors.greenAccent[700]!),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: TextField(
            onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Search name or email...",
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.green),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ["All", "Admin", "Volunteer", "User"].map((filter) {
              bool isSelected = activeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter.capitalizeFirst!),
                  selected: isSelected,
                  onSelected: (val) => setState(() => activeFilter = filter),
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pressElevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.grey[200]!,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final filtered = snapshot.data!.docs.where((doc) {
          String name = doc['name'].toString().toLowerCase();
          String email = doc['email'].toString().toLowerCase();
          String role = doc['role'] ?? 'user';
          bool matchesSearch =
              name.contains(searchQuery) || email.contains(searchQuery);
          bool matchesFilter = activeFilter == "All" || role == activeFilter;
          return matchesSearch && matchesFilter;
        }).toList();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            var data = filtered[index].data() as Map<String, dynamic>;
            String role = data['role'] ?? 'user';
            String name = data['name'] ?? "Unknown";
            String? profileImg = data['profileImage'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () => Get.to(
                  () => UserDetailScreen(
                    userName: name,
                    userEmail: data['email'],
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getRoleColor(role).withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    backgroundImage:
                        (profileImg != null && profileImg.isNotEmpty)
                        ? MemoryImage(base64Decode(profileImg))
                        : null,
                    child: (profileImg == null || profileImg.isEmpty)
                        ? Text(
                            name[0],
                            style: TextStyle(
                              color: _getRoleColor(role),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  data['email'] ?? "",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                trailing: _buildRoleBadge(role, filtered[index].id, name),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoleBadge(String role, String uid, String name) {
    return InkWell(
      onTap: () => _showRoleDialog(uid, role, name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getRoleColor(role).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: _getRoleColor(role),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 10, color: _getRoleColor(role)),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    if (role == 'Admin') return Colors.redAccent;
    if (role == 'Volunteer') return Colors.blueAccent;
    return Colors.green;
  }
}
