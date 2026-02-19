import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart'; // 🔥 Ensure this is imported

class VolRequestStatusPage extends StatelessWidget {
  const VolRequestStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Get the current user's UID to match against 'volunteer_id' in Firestore
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: uid == null
          ? const Center(child: Text("Please log in to view requests"))
          : StreamBuilder<QuerySnapshot>(
              // 🔥 Querying the top-level 'volunteer_requests' collection
              stream: FirebaseFirestore.instance
                  .collection('volunteer_requests')
                  .where('volunteer_id', isEqualTo: uid)
                  .orderBy('requested_at', descending: true)
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

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "You haven't applied for any events yet.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var requestData =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey[50],
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: const Icon(
                                      Icons.event_note,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      requestData['event_title'] ??
                                          "Untitled Event",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  _buildStatusChip(
                                    requestData['status'] ?? "pending",
                                  ),
                                ],
                              ),
                            ),

                            // 🔥 UPDATED SUBTITLE WITH READMORETEXT
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.psychology,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Skills applied:",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ReadMoreText(
                                    requestData['skills'] ?? 'Not specified',

                                    // "Skills: ${requestData['skills'] ?? 'N/A'}",
                                    trimLines: 2,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: ' Show more',
                                    trimExpandedText: ' Show less',
                                    moreStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                    lessStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _infoTile(
                                        Icons.calendar_month,
                                        "Requested on",
                                        _formatDate(
                                          requestData['requested_at'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.green[400]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    DateTime date = (timestamp as Timestamp).toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayStatus = status.toLowerCase();

    if (displayStatus == 'approved') {
      chipColor = Colors.green;
    } else if (displayStatus == 'rejected') {
      chipColor = Colors.red;
    } else {
      chipColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
