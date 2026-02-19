import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  // --- MASK USER EMAIL/NAME ---
  String maskUserName(String input) {
    if (input == "Anonymous" || !input.contains('@')) return input;
    final parts = input.split('@');
    final name = parts[0];
    if (name.length <= 2) return "${name[0]}***@${parts[1]}";
    return "${name[0]}***${name[name.length - 1]}@${parts[1]}";
  }

  // --- LOGIC STREAMS ---
  Stream<double> _getReceivedFunds() {
    return FirebaseFirestore.instance.collection('donations').snapshots().map((
      snapshot,
    ) {
      double totalReceived = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data();
        String amountStr = data['amount_inr']
            .toString()
            .replaceAll(RegExp(r'[^0-9.]'), '')
            .trim();
        totalReceived += double.tryParse(amountStr) ?? 0;
      }
      return totalReceived;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F7FA,
      ), // Modern subtle blue-grey background
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. WELCOME HEADER
          // _buildSliverHeader(),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 2. STATS GRID (Dynamic & Elevated)
                _buildStatsGrid(),

                const SizedBox(height: 30),

                // 3. RECENT ACTIVITY HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text("View All")),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. RECENT DONATIONS LIST
                _buildRecentDonationsList(currencyFormat),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.2,
      children: [
        StreamBuilder<double>(
          stream: _getReceivedFunds(),
          builder: (context, snapshot) {
            return _modernStatUI(
              "Total Funds",
              "₹${snapshot.data?.toStringAsFixed(0) ?? '0'}",
              Icons.account_balance_wallet_rounded,
              Colors.teal,
            );
          },
        ),
        _buildStreamStatCard(
          "Approved Vol.",
          "volunteer_requests",
          Icons.verified_user_rounded,
          Colors.blue,
          isVolunteer: true,
        ),
        _buildStreamStatCard(
          "Active Events",
          "events",
          Icons.event_available_rounded,
          Colors.green,
          isEvent: true,
        ),
        _buildStreamStatCard(
          "Categories",
          "donation_categories",
          Icons.category_rounded,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _modernStatUI(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStreamStatCard(
    String title,
    String collection,
    IconData icon,
    Color color, {
    bool isVolunteer = false,
    bool isEvent = false, // 🔥 Add a new flag for Events
  }) {
    Query query = FirebaseFirestore.instance.collection(collection);

    // 1. Filter for Approved Volunteers
    if (isVolunteer) {
      query = query.where('status', isEqualTo: 'approved');
    }

    // 2. 🔥 Filter for ACTIVE Events (Today or Future)
    if (isEvent) {
      // We get today's date at 00:00:00 to ensure events happening today are shown
      DateTime now = DateTime.now();
      DateTime todayStart = DateTime(now.year, now.month, now.day);

      query = query.where(
        'event_date_timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        // Show "0" if data is loaded but empty, otherwise show "..."
        String count = snapshot.hasData
            ? snapshot.data!.docs.length.toString()
            : "...";

        return _modernStatUI(title, count, icon, color);
      },
    );
  }

  Widget _buildRecentDonationsList(NumberFormat currencyFormat) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .orderBy('created_at', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String maskedUser = maskUserName(data['user_email'] ?? "Anonymous");
            String category = data['title'] ?? "General";
            double amount =
                double.tryParse(
                  data['amount_inr'].toString().replaceAll(
                    RegExp(r'[^0-9.]'),
                    '',
                  ),
                ) ??
                0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green[50],
                    child: const Icon(
                      Icons.person,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maskedUser,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildCategoryBadge(category),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(amount),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
