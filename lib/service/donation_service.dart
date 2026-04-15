import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> saveDonation({
    required String title,
    required double amountInr,
    required double amountUsd,
    required Map paypalResponse,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    await _firestore.collection('donations').add({
      'user_id': user.uid,
      'user_email': user.email,
      'title': title,
      'amount_inr': amountInr,
      'amount_usd': amountUsd,
      'payment_id': paypalResponse['paymentId'] ?? '',
      'payer_email': paypalResponse['payer']?['payer_info']?['email'] ?? '',
      'status': 'success',
      'created_at': FieldValue.serverTimestamp(),
      'paypal_response': paypalResponse,
    });
  }
}
