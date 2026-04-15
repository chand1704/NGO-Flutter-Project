import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ngo_project/Model/Donation_Item.dart';

import 'donate_payment_page.dart';

class DonationDetailsPage extends StatelessWidget {
  final String categoryName;
  final String? categoryImage; // The Base64 image from Firestore
  final List<DonationItem> details;

  const DonationDetailsPage({
    super.key,
    required this.categoryName,
    this.categoryImage,
    required this.details,
  });

  String _getStaticArea(String category) {
    switch (category) {
      case "Old Age":
        return " Pasodara Center & "
            "Mota Varachha, Surat Center";
      case "Tree":
        return " Green Belt Area (NH-48) & Sarthana Park";

      case "Education":
        return " Helping Hands Primary Wing & Katargam School";

      case "Medical":
        return " Community Health Camp (Surat) & Adajan Clinic";

      case "Food":
        return " NGO Kitchen (Varachha) & Puna Area Distribution";

      case "Cow Shelter":
        return " Goshala (Kamrej) & Bhestan Shelter";

      default:
        return " All Active NGO Branches in Gujarat";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String targetArea = _getStaticArea(categoryName);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. IMMERSIVE CATEGORY HEADER
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.green.shade900,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                categoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // DECODED CATEGORY IMAGE
                  _buildHeaderImage(),
                  // CINEMATIC GRADIENT
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. TIER SELECTION SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Choose Your Impact",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Beneficiary Area:",
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        targetArea,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select a donation tier below to support $categoryName.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          // 3. DONATION ITEMS
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildTierCard(context, details[index], targetArea),
                childCount: details.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    if (categoryImage != null && categoryImage!.isNotEmpty) {
      return Image.memory(base64Decode(categoryImage!), fit: BoxFit.cover);
    }
    // Fallback if no image is provided
    return Container(
      color: Colors.green.shade800,
      child: const Icon(
        Icons.volunteer_activism,
        color: Colors.white,
        size: 80,
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, DonationItem item, String area) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item.amount,
            style: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        trailing: const Icon(Icons.arrow_forward_rounded, color: Colors.green),
        onTap: () {
          HapticFeedback.lightImpact(); // Professional haptic feel
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DonatePaymentPage(item: item, targetArea: area),
            ),
          );
        },
      ),
    );
  }
}
