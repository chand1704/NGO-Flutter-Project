import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDonationChart extends StatelessWidget {
  const AdminDonationChart({super.key});
  String maskUserName(String name) {
    if (name.isEmpty || name == "Anonymous") return "Anonymous";
    if (name.contains('@')) {
      var parts = name.split('@');
      String prefix = parts[0];
      if (prefix.length > 2) {
        return "${prefix.substring(0, 2)}***${prefix.substring(prefix.length - 1)}@${parts[1]}";
      }
    }
    return name.length > 8 ? "${name.substring(0, 8)}..." : name;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    int currentYear = DateTime.now().year;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
          if (snapshot.hasError)
            return const Center(child: Text("Error syncing data"));
          Map<int, double> monthlyTotals = {
            for (var i = 0; i < 12; i++) i: 0.0,
          };
          double totalSum = 0;
          double maxMonthVal = 1000;
          List<DocumentSnapshot> donationDocs = snapshot.data?.docs ?? [];
          for (var doc in donationDocs) {
            var data = doc.data() as Map<String, dynamic>;
            double amount = (data['amount_inr'] ?? 0).toDouble();
            Timestamp? ts = data['created_at'] as Timestamp?;
            if (ts != null) {
              DateTime date = ts.toDate();
              if (date.year == currentYear) {
                int month = date.month - 1;
                monthlyTotals[month] = (monthlyTotals[month] ?? 0) + amount;
                if (monthlyTotals[month]! > maxMonthVal)
                  maxMonthVal = monthlyTotals[month]!;
              }
              totalSum += amount;
            }
          }
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. DYNAMIC REVENUE HEADER
              SliverToBoxAdapter(
                child: _buildRevenueHeader(
                  totalSum,
                  currencyFormat,
                  currentYear,
                ),
              ),
              // 2. ANALYTICAL TREND CHART
              SliverToBoxAdapter(
                child: _buildTrendChart(monthlyTotals, maxMonthVal),
              ),
              // 3. RECENT TRANSACTIONS LABEL
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
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
                      Icon(Icons.filter_list, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
              // 4. TRANSACTION LIST
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var data = donationDocs[index].data() as Map<String, dynamic>;
                  return _buildModernTransactionTile(data, currencyFormat);
                }, childCount: donationDocs.length),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRevenueHeader(double total, NumberFormat format, int year) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 40, 25, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ANNUAL REVENUE • $year",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            format.format(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _headerInfoChip(
                "Monthly Avg",
                format.format(total / 12),
                Icons.auto_graph_rounded,
              ),
              const SizedBox(width: 15),
              _headerInfoChip(
                "Transactions",
                "Total: ${total > 0 ? 'Active' : 'N/A'}",
                Icons.history,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfoChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(Map<int, double> totals, double max) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.fromLTRB(10, 25, 20, 10),
      height: 280,
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
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: _buildChartTitles(),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: max * 1.3,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                12,
                (i) => FlSpot(i.toDouble(), totals[i] ?? 0),
              ),
              isCurved: true,
              color: const Color(0xFF2E7D32),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    const Color(0xFF4CAF50).withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _buildChartTitles() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (val, meta) {
            const months = [
              'J',
              'F',
              'M',
              'A',
              'M',
              'J',
              'J',
              'A',
              'S',
              'O',
              'N',
              'D',
            ];
            return SideTitleWidget(
              meta: meta,
              child: Text(
                months[val.toInt()],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernTransactionTile(
    Map<String, dynamic> data,
    NumberFormat format,
  ) {
    String maskedUser = maskUserName(data['user_email'] ?? "Anonymous");
    double amt = (data['amount_inr'] ?? 0).toDouble();
    Timestamp? ts = data['created_at'] as Timestamp?;
    String date = ts != null
        ? DateFormat('dd MMM').format(ts.toDate())
        : "Recent";
    String title = data['title'] ?? "General Donation";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
                  maskedUser,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                format.format(amt),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
