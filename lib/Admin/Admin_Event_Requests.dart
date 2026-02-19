import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEventRequests extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const AdminEventRequests({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  // --- LOGIC: STATUS UPDATE ---
  Future<void> _updateStatus(String volunteerId, String status) async {
    String customDocId = "${eventId}_$volunteerId";
    try {
      await FirebaseFirestore.instance
          .collection('volunteer_requests')
          .doc(customDocId)
          .update({'status': status});

      Get.snackbar(
        "Decision Recorded",
        "Volunteer status moved to ${status.toUpperCase()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: status == 'approved'
            ? Colors.green[800]
            : Colors.red[800],
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 15,
        icon: Icon(
          status == 'approved' ? Icons.check_circle : Icons.cancel,
          color: Colors.white,
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Sync Error",
        "Could not update status",
        backgroundColor: Colors.orange,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6), // Modern soft background
      appBar: AppBar(
        title: Text(
          eventTitle,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('volunteer_requests')
            .where('event_id', isEqualTo: eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          final requests = snapshot.data?.docs ?? [];
          int approved = requests
              .where((d) => d['status'] == 'approved')
              .length;
          int pending = requests.where((d) => d['status'] == 'pending').length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. ANALYTICAL HEADER
              SliverToBoxAdapter(
                child: _buildManagementHeader(
                  requests.length,
                  approved,
                  pending,
                ),
              ),

              // 2. REQUESTS LIST
              requests.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          var reqData =
                              requests[index].data() as Map<String, dynamic>;
                          return _buildModernRequestCard(reqData);
                        }, childCount: requests.length),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  // --- UI: MANAGEMENT HEADER ---
  Widget _buildManagementHeader(int total, int approved, int pending) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _headerStatItem("Applied", "$total", Colors.grey),
          _headerStatItem("Approved", "$approved", Colors.green),
          _headerStatItem("Pending", "$pending", Colors.orange),
        ],
      ),
    );
  }

  Widget _headerStatItem(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  // --- UI: MODERN REQUEST CARD ---
  Widget _buildModernRequestCard(Map<String, dynamic> reqData) {
    String status = reqData['status'] ?? "pending";
    String vId = reqData['volunteer_id'] ?? "";
    Color statusColor = status == 'approved'
        ? Colors.green
        : (status == 'rejected' ? Colors.red : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserHeader(vId, status, statusColor),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(height: 1),
                    ),
                    const Text(
                      "SKILLS STATEMENT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reqData['skills'] ?? "General volunteer support.",
                      style: TextStyle(
                        color: Colors.blueGrey[800],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _actionBtn(
                            "DECLINE",
                            Colors.red,
                            () => _updateStatus(vId, 'rejected'),
                            true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionBtn(
                            "APPROVE",
                            Colors.green,
                            () => _updateStatus(vId, 'approved'),
                            false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(String vId, String status, Color color) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(vId).get(),
      builder: (context, userSnap) {
        String name = userSnap.data?['name'] ?? "Volunteer";
        return Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              radius: 20,
              child: Text(
                name[0],
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
            ),
            _buildStatusChip(status, color),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _actionBtn(
    String label,
    Color color,
    VoidCallback onTap,
    bool isOutline,
  ) {
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutline
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isOutline ? Colors.grey[600] : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 15),
          const Text(
            "No Requests Found",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
