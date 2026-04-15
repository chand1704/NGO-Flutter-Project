import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Donation_details.dart';
import 'Model/Category_Model.dart';
import 'Model/Donation_Item.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donation_categories')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Error loading missions"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String categoryKey = data['category_id'] ?? docs[index].id;
              final category = CategoryModel.fromFirestore(data, categoryKey);
              final List<DonationItem> details = (data['items'] as List? ?? [])
                  .map(
                    (item) =>
                        DonationItem.fromMap(item as Map<String, dynamic>),
                  )
                  .toList();
              return _buildPremiumMissionCard(context, category, details);
            },
          );
        },
      ),
    );
  }

  Widget _buildPremiumMissionCard(
    BuildContext context,
    CategoryModel category,
    List<DonationItem> details,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () => _handleTap(context, category, details),
          child: Stack(
            children: [
              // 1. Background Image / Fallback
              SizedBox(
                height: 200,
                width: double.infinity,
                child: _buildCategoryImage(category),
              ),

              // 2. Cinematic Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
              // 3. Mission Details Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text(
                            "ACTIVE MISSION",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Every small contribution brings hope to those in need of ${category.title.toLowerCase()}.",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(CategoryModel category) {
    if (category.base64Image != null && category.base64Image!.isNotEmpty) {
      return Image.memory(
        base64Decode(category.base64Image!),
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) =>
            Image.asset(category.fallbackImage, fit: BoxFit.cover),
      );
    }
    return Image.asset(category.fallbackImage, fit: BoxFit.cover);
  }

  void _handleTap(
    BuildContext context,
    CategoryModel category,
    List<DonationItem> details,
  ) {
    if (details.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationDetailsPage(
            categoryName: category.title,
            details: details,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stay tuned! Donation options opening soon."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
