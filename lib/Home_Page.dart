import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ngo_project/root.dart';

import 'Auto_Slider.dart';
import 'Donate_Page.dart';
import 'MyDonationPage.dart';
import 'Profile_Page.dart';
import 'User_Event.dart';
import 'service/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<String> _pageTitles = [
    "Helping Hand NGO",
    "Donate Now",
    "My Profile",
    "Impact History",
    "Upcoming Events",
  ];
  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(onDonateTap: () => _onItemTapped(1)),
      DonatePage(),
      const ProfilePage(),
      MyDonationPage(),
      UserEvent(),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.lightImpact();
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: Colors.green.withValues(alpha: 0.75),
              elevation: 0,
              centerTitle: true,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(
                    Icons.menu_open_rounded,
                    color: Colors.black87,
                    size: 28,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _pageTitles[_selectedIndex],
                  key: ValueKey(_selectedIndex),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.green,
                      size: 24,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildPremiumDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: _buildGlassBottomBar(),
    );
  }

  Widget _buildGlassBottomBar() {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 0),
              _buildNavItem(Icons.volunteer_activism_rounded, 1),
              _buildNavItem(Icons.person_rounded, 2),
              _buildNavItem(Icons.history_rounded, 3),
              _buildNavItem(Icons.event_note_rounded, 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isActive ? 10 : 8),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.green.shade800 : Colors.grey.shade400,
              size: isActive ? 28 : 24,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: isActive ? 14 : 0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.green.shade400],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDrawer() {
    final User user = FirebaseAuth.instance.currentUser!;
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(user),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _drawerTile(Icons.home_rounded, "Overview", 0),
                _drawerTile(
                  Icons.volunteer_activism_rounded,
                  "Support a Cause",
                  1,
                ),
                _drawerTile(Icons.person_rounded, "My Profile", 2),
                _drawerTile(Icons.history_rounded, "Impact History", 3),
                _drawerTile(Icons.event_rounded, "NGO Events", 4),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(thickness: 1, height: 1),
                ),
                _drawerLogoutTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerLogoutTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        title: const Text(
          "Sign Out",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          HapticFeedback.heavyImpact();
          await AuthService().signOut();
          Get.offAll(() => const Root());
        },
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, int index) {
    bool isActive = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.green.shade800 : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.green.shade800 : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        onTap: () {
          _onItemTapped(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildDrawerHeader(User user) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(25, 70, 25, 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green.shade900, Colors.green.shade600],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: (data['profileImage'] != null)
                      ? MemoryImage(
                          base64Decode(
                            data['profileImage'].toString().split(',').last,
                          ),
                        )
                      : null,
                  child: (data['profileImage'] == null)
                      ? const Icon(Icons.person, size: 40, color: Colors.green)
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                data['name'] ?? "Kind Soul",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                data['email'] ?? "",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ImpactMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  ImpactMetric(this.label, this.value, this.icon, this.color);
}

class CategoryModel {
  final String id;
  final String title;
  final String? base64Image;
  final IconData icon;
  final String fallbackImage;
  final List<dynamic> items;
  CategoryModel({
    required this.id,
    required this.title,
    this.base64Image,
    required this.icon,
    required this.fallbackImage,
    this.items = const [],
  });
  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String docId) {
    final meta = _getLocalMetadata(docId);
    return CategoryModel(
      id: docId,
      title: data['category_name'] ?? 'Unnamed Category',
      base64Image: data['image'],
      items: data['items'] as List? ?? [],
      icon: meta['icon'],
      fallbackImage: meta['imagePath'],
    );
  }
  static Map<String, dynamic> _getLocalMetadata(String id) {
    final Map<String, Map<String, dynamic>> metaMap = {
      "old_age": {
        "icon": Icons.elderly,
        "imagePath": "assets/images/old_age.jpg",
      },
      "tree": {"icon": Icons.park, "imagePath": "assets/images/tree.jpeg"},
      "food": {"icon": Icons.restaurant, "imagePath": "assets/images/food.jpg"},
    };
    return metaMap[id] ??
        {"icon": Icons.help, "imagePath": "assets/images/ngo_logo.png"};
  }
}

class HomeContent extends StatelessWidget {
  final VoidCallback onDonateTap;
  final List<ImpactMetric> metrics = [
    ImpactMetric("Lives Saved", "15k+", Icons.favorite, Colors.redAccent),
    ImpactMetric("Kids Taught", "4.2k", Icons.school, Colors.blue),
    ImpactMetric("Meals Served", "50k+", Icons.restaurant, Colors.orange),
  ];
  HomeContent({super.key, required this.onDonateTap});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // 1. DYNAMIC HEADER SLIDER
                const AutoSlider(),
                const SizedBox(height: 25),
                // 2. REAL-TIME IMPACT SECTION
                const _SectionTitle(title: "Our Real-Time Impact"),
                const SizedBox(height: 15),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: metrics.length,
                    itemBuilder: (context, index) =>
                        _buildImpactCard(metrics[index]),
                  ),
                ),
                const SizedBox(height: 30),
                // 3. CAUSES STREAM SECTION
                const _SectionTitle(title: "Support a Cause"),
                const SizedBox(height: 15),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('donation_categories')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return const Text("Error loading causes");
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    return SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final category = CategoryModel.fromFirestore(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: _buildFeaturedActionCard(
                                context,
                                title: category.title,
                                subtitle:
                                    "Help support our ${category.title} initiatives.",
                                base64Image: category.base64Image,
                                fallbackPath: category.fallbackImage,
                                onTap: onDonateTap,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                // 4. ACTION TILES
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.volunteer_activism,
                        label: "Quick Donate",
                        color: Colors.green.shade600,
                        onTap: onDonateTap,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.handshake,
                        label: "Be a Volunteer",
                        color: Colors.indigo,
                        onTap: () => _showVolunteerSnackbar(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? base64Image,
    required String fallbackPath,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: (base64Image != null && base64Image.isNotEmpty)
              ? MemoryImage(base64Decode(base64Image)) as ImageProvider
              : AssetImage(fallbackPath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Badge(label: Text("Featured"), backgroundColor: Colors.orange),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Support Now"),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(ImpactMetric metric) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(metric.icon, color: metric.color, size: 28),
          const SizedBox(height: 5),
          Text(
            metric.value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            metric.label,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showVolunteerSnackbar(BuildContext context) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "You want to create a volunteer account And signout to this account",

          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.indigo.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
