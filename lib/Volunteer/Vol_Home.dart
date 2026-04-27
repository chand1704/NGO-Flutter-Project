import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngo_project/root.dart';
import 'package:ngo_project/service/auth_service.dart';

import 'Vol_EventsPage.dart';
import 'Vol_ProfilePage.dart';
import 'Vol_RequestStatusPage.dart';

class VolHome extends StatefulWidget {
  const VolHome({super.key});

  @override
  State<VolHome> createState() => _VolHomeState();
}

class _VolHomeState extends State<VolHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const VolunteerDashboard(),
    const VolEventsPage(),
    const VolProfilePage(),
    const VolRequestStatusPage(key: PageStorageKey('requests_tab')),
  ];

  final List<String> _titles = [
    "Volunteer Home",
    "Upcoming Events",
    "My Profile",
    "Requests",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () {
          _onItemTapped(index);
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        selected: isSelected,
        selectedTileColor: Colors.green.withValues(alpha: 0.1),
        leading: Icon(
          icon,
          color: isSelected ? Colors.green : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      drawer: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // --- CUSTOM HEADER SECTION ---
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(AuthService().currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                var userData = snapshot.data?.data() as Map<String, dynamic>?;
                String name = userData?['name'] ?? "Volunteer";
                String email = userData?['email'] ?? "";
                String? profileImage = userData?['profileImage'];

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with white ring
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              (profileImage != null && profileImage.isNotEmpty)
                              ? (profileImage.startsWith('http')
                                  ? NetworkImage(profileImage)
                                  : MemoryImage(
                                      base64Decode(profileImage.trim()),
                                    ) as ImageProvider)
                              : null,
                          child: (profileImage == null || profileImage.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // --- MENU ITEMS ---
            _buildDrawerItem(Icons.home_rounded, "Home", 0),
            _buildDrawerItem(Icons.event_note_rounded, "Events", 1),
            _buildDrawerItem(Icons.person_rounded, "My Profile", 2),
            _buildDrawerItem(Icons.fact_check_rounded, "My Requests", 3),

            const Spacer(), // Pushes logout to the bottom
            // --- FOOTER SECTION ---
            const Divider(indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                onTap: () async {
                  await AuthService().signOut();
                  Get.offAll(() => const Root());
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
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
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "Helping hand NGO",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_rounded),
            label: 'Requests',
          ),
        ],
      ),
    );
  }
}

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = AuthService().currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. DYNAMIC HEADER WITH SLIVER
          _buildSliverHeader(uid),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. MODERN STATS SECTION
                  _buildDynamicStats(uid),

                  // const SizedBox(height: 30),
                  //
                  // // 3. CATEGORY CHIPS (Dynamic feel)
                  // const Text(
                  //   "Explore Categories",
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 12),

                  // _buildCategoryList(),
                  const SizedBox(height: 30),

                  // 4. FEATURED EVENTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Latest Opportunities",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context
                            .findAncestorStateOfType<_VolHomeState>()
                            ?._onItemTapped(1),
                        child: const Text("See All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          // 5. HORIZONTAL EVENTS LIST
          SliverToBoxAdapter(child: _buildDynamicImageEvents()),

          // 6. ACTION CARDS
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildModernActionCard(
                  Icons.volunteer_activism,
                  "Explore Events",
                  "Browse upcoming opportunities",
                  Colors.green,
                  () => context
                      .findAncestorStateOfType<_VolHomeState>()
                      ?._onItemTapped(1),
                ),
                const SizedBox(height: 12),
                _buildModernActionCard(
                  Icons.history_edu,
                  "My Requests",
                  "Track your application status",
                  Colors.blue,
                  () => context
                      .findAncestorStateOfType<_VolHomeState>()
                      ?._onItemTapped(3),
                ),
                const SizedBox(height: 50), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT: SLIVER HEADER ---
  Widget _buildSliverHeader(String uid) {
    return SliverAppBar(
      expandedHeight: 120.0,
      automaticallyImplyLeading: false, // Hide back button
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Color(0xFF1B5E20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String name = snapshot.data?['name'] ?? "Hero";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "$name! 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- COMPONENT: CATEGORY LIST ---
  // Widget _buildCategoryList() {
  //   List<Map<String, dynamic>> categories = [
  //     {"name": "Education", "icon": Icons.school, "color": Colors.blue},
  //     {"name": "Nature", "icon": Icons.eco, "color": Colors.green},
  //     {"name": "Medical", "icon": Icons.medical_services, "color": Colors.red},
  //     {"name": "Food", "icon": Icons.fastfood, "color": Colors.orange},
  //   ];
  //   return SizedBox(
  //     height: 45,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: categories.length,
  //       itemBuilder: (context, index) {
  //         return Container(
  //           margin: const EdgeInsets.only(right: 10),
  //           child: ActionChip(
  //             avatar: Icon(
  //               categories[index]['icon'],
  //               size: 16,
  //               color: categories[index]['color'],
  //             ),
  //             label: Text(categories[index]['name']),
  //             backgroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //               side: BorderSide(color: Colors.grey[200]!),
  //             ),
  //             onPressed: () {},
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // --- COMPONENT: DYNAMIC STATS (GRADIENT CARDS) ---
  Widget _buildDynamicStats(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('volunteer_requests')
          .where('volunteer_id', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              _buildStatCard(
                "Active Applications",
                "...",
                Colors.orange,
                Icons.assignment_turned_in,
              ),
              const SizedBox(width: 15),
              _buildStatCard(
                "Impact Points",
                "...",
                Colors.blueAccent,
                Icons.auto_awesome,
              ),
            ],
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // Logic: Active = Pending OR Approved (not rejected)
        int activeCount = docs.where((doc) {
          String status = (doc['status'] ?? "pending").toString().toLowerCase();
          return status == 'pending' || status == 'approved';
        }).length;

        // Logic: Impact points only from Approved applications
        int approvedCount = docs.where((doc) {
          return (doc['status'] ?? "").toString().toLowerCase() == 'approved';
        }).length;
        int impactPoints = approvedCount * 100;

        return Row(
          children: [
            _buildStatCard(
              "Active Applications",
              "$activeCount",
              Colors.orange,
              Icons.assignment_turned_in,
            ),
            const SizedBox(width: 15),
            _buildStatCard(
              "Impact Points",
              "$impactPoints",
              Colors.blueAccent,
              Icons.auto_awesome,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicImageEvents() {
    return SizedBox(
      height: 250,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('event_date_timestamp', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var event =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String? img = event['image'];

              // 🔥 PRECISION LOGIC: Blur only if the DATE has fully passed
              bool isPast = false;
              if (event['event_date_timestamp'] != null) {
                DateTime eventDate =
                    (event['event_date_timestamp'] as Timestamp).toDate();

                // Create a "Today" object at 00:00:00 time
                DateTime today = DateTime.now();
                DateTime justDateToday = DateTime(
                  today.year,
                  today.month,
                  today.day,
                );

                // Create an "EventDate" object at 00:00:00 time
                DateTime justDateEvent = DateTime(
                  eventDate.year,
                  eventDate.month,
                  eventDate.day,
                );

                // It only becomes "Past" if the event date is strictly BEFORE today's date
                // If event is Jan 28 and today is Jan 28, this is FALSE (not blurred)
                // If event is Jan 28 and today is Jan 29, this is TRUE (blurred)
                isPast = justDateEvent.isBefore(justDateToday);
              }

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Opacity(
                  opacity: isPast ? 0.6 : 1.0, // Dims the card on the 29th
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: ColorFiltered(
                                colorFilter: isPast
                                    ? const ColorFilter.mode(
                                        Colors.grey,
                                        BlendMode.saturation,
                                      )
                                    : const ColorFilter.mode(
                                        Colors.transparent,
                                        BlendMode.multiply,
                                      ),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: img != null
                                      ? Image.memory(
                                          base64Decode(img),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(color: Colors.grey),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _buildStatusTag(isPast),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          event['event_title'] ?? "Event",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPast ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- COMPONENT: STATUS TAG BUILDER ---
  Widget _buildStatusTag(bool isPast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPast ? Colors.black54 : Colors.green.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPast ? "COMPLETED" : "ACTIVE",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModernActionCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
