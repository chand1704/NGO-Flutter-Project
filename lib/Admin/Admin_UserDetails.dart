import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDetailScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  const UserDetailScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });
  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "User Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('user_email', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
          var docs = snapshot.data?.docs ?? [];
          docs.sort((a, b) {
            var aData = a.data() as Map<String, dynamic>;
            var bData = b.data() as Map<String, dynamic>;
            Timestamp? aTs = aData['created_at'];
            Timestamp? bTs = bData['created_at'];
            if (aTs == null || bTs == null) return 0;
            return aTs.compareTo(bTs);
          });
          double totalContribution = 0;
          List<FlSpot> spots = [];
          double maxY = 1000;
          for (int i = 0; i < docs.length; i++) {
            var data = docs[i].data() as Map<String, dynamic>;
            double amt = 0;
            var rawAmt = data['amount_inr'];
            if (rawAmt is num) {
              amt = rawAmt.toDouble();
            } else if (rawAmt is String) {
              amt =
                  double.tryParse(rawAmt.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                  0;
            }
            totalContribution += amt;
            if (amt > maxY) maxY = amt;
            spots.add(FlSpot(i.toDouble(), amt));
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(totalContribution, currencyFormat),
                const SizedBox(height: 25),
                if (spots.length > 1)
                  _buildChartSection(spots, maxY)
                else if (docs.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "More donations needed to generate a trend chart.",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 30),
                _buildHistoryHeader(),
                if (docs.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data =
                          docs[docs.length - 1 - index].data()
                              as Map<String, dynamic>;
                      return _buildDonationCard(data, currencyFormat);
                    },
                  ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(double total, NumberFormat format) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              userName.isNotEmpty
                  ? userName.substring(0, 1).toUpperCase()
                  : "U",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            userEmail,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "TOTAL CONTRIBUTION",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  format.format(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<FlSpot> spots, double maxY) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Contribution Analysis",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 2.0,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3,
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> data, NumberFormat format) {
    Timestamp? ts = data['created_at'];
    String dateStr = ts != null
        ? DateFormat('dd MMM yyyy').format(ts.toDate())
        : "Recent";
    double amt = 0;
    var rawAmt = data['amount_inr'];
    if (rawAmt is num)
      amt = rawAmt.toDouble();
    else if (rawAmt is String)
      amt = double.tryParse(rawAmt.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? "General Donation",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            format.format(amt),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Transaction History",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Column(
      children: [
        SizedBox(height: 40),
        Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
        SizedBox(height: 10),
        Text(
          "No donations found for this user.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
