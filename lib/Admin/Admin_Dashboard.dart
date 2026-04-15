import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngo_project/Admin/Admin_Event.dart';
import 'package:ngo_project/service/auth_service.dart';

import '../Sign_In_Page.dart';
import '../root.dart';
import 'Admin_Category.dart';
import 'Admin_Donation_Chart.dart';
import 'Admin_HomeDashboard.dart';
import 'Admin_User_Management.dart';

class AdminNavController extends GetxController {
  var currentIndex = 0.obs;
  void changeIndex(int index) => currentIndex.value = index;
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final navController = Get.put(AdminNavController());
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    final List<Widget> screens = [
      const AdminHomeScreen(),
      const UserManagementScreen(),
      const AdminDonationChart(),
      const AdminCategoryScreen(),
      const AdminEventScreen(),
    ];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Obx(() {
          switch (navController.currentIndex.value) {
            case 0:
              return const Text(
                "Admin Overview",
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            case 1:
              return const Text(
                "User Directory",
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            case 2:
              return const Text(
                "Donation Insights",
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            case 3:
              return const Text(
                "Categories",
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            case 4:
              return const Text(
                "Event Manager",
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            default:
              return const Text("Admin Portal");
          }
        }),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      drawer: _buildModernDrawer(context, uid, navController),
      body: Obx(
        () => IndexedStack(
          index: navController.currentIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(navController),
    );
  }

  Widget _buildModernDrawer(
    BuildContext context,
    String? uid,
    AdminNavController navController,
  ) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(uid),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDrawerItem(
                  Icons.grid_view_rounded,
                  "Dashboard",
                  0,
                  navController,
                ),
                _buildDrawerItem(
                  Icons.people_alt_rounded,
                  "User Management",
                  1,
                  navController,
                ),
                _buildDrawerItem(
                  Icons.bar_chart_rounded,
                  "Donation Stats",
                  2,
                  navController,
                ),
                _buildDrawerItem(
                  Icons.category_rounded,
                  "Categories",
                  3,
                  navController,
                ),
                _buildDrawerItem(
                  Icons.event_available_rounded,
                  "Events",
                  4,
                  navController,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(),
                ),
                ListTile(
                  onTap: () async {
                    await AuthService().signOut();
                    Get.offAll(() => const Root());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.red),
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "v1.0.4 - Helping Hand NGO",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(String? uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        var data = snapshot.data?.data() as Map<String, dynamic>?;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[700]!, Colors.green[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(50),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 40,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                data?['name'] ?? "Admin User",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                data?['email'] ?? "admin@ngo.com",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    int index,
    AdminNavController controller,
  ) {
    return Obx(() {
      bool isSelected = controller.currentIndex.value == index;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          onTap: () {
            controller.changeIndex(index);
            Get.back();
          },
          leading: Icon(
            icon,
            color: isSelected ? Colors.green[700] : Colors.grey[600],
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.green[700] : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedTileColor: Colors.green[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    });
  }

  Widget _buildBottomNav(AdminNavController navController) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: navController.currentIndex.value,
            onTap: navController.changeIndex,
            selectedItemColor: Colors.green[700],
            unselectedItemColor: Colors.grey[500],
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                label: "Dashboard",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_rounded),
                label: "Users",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: "Donation",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_rounded),
                label: "Categories",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_available_rounded),
                label: "Events",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
