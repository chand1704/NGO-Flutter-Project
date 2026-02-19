import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Model/donation_model.dart';
import 'donation_receipt_page.dart';

class MyDonationPage extends StatelessWidget {
  MyDonationPage({super.key});

  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC), // Premium off-white
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('user_id', isEqualTo: userId)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // Calculate Total Impact locally for the header
          double totalImpact = 0;
          for (var doc in docs) {
            totalImpact += (doc['amount_inr'] ?? 0).toDouble();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(), // Organic scrolling feel
            slivers: [
              // 1. DYNAMIC IMPACT HEADER
              SliverToBoxAdapter(
                child: _buildImpactHeader(totalImpact, docs.length),
              ),

              // 2. TRANSACTION LIST
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                sliver: docs.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final donation = DonationModel.fromJson(
                            docs[index].data() as Map<String, dynamic>,
                          );
                          return _buildPremiumDonationCard(context, donation);
                        }, childCount: docs.length),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImpactHeader(double total, int count) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Total Impact",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${total.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count Contribution${count == 1 ? '' : 's'}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDonationCard(
    BuildContext context,
    DonationModel donation,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.volunteer_activism_rounded,
            color: Colors.green,
          ),
        ),
        title: Text(
          donation.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        subtitle: const Text(
          "Success",
          style: TextStyle(
            color: Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "₹${donation.amountInr}",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
        onTap: () {
          HapticFeedback.lightImpact(); // Professional tactile feedback
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonationReceiptPage(donation: donation),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.spa_rounded, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          "Your journey begins here",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }
}
