import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Model/donation_model.dart';
import 'donation_receipt_page.dart';

class DonationHistoryPage extends StatelessWidget {
  const DonationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Donations')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('user_id', isEqualTo: user.uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No donations yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];

              final donation = DonationModel.fromJson(
                doc.data() as Map<String, dynamic>,
              );

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(donation.title ?? "N/A"),
                  subtitle: Text('₹${donation.amountInr?.toStringAsFixed(0)}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DonationReceiptPage(donation: donation),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
