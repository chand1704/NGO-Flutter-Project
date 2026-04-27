import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class VolEventsPage extends StatefulWidget {
  const VolEventsPage({super.key});

  @override
  State<VolEventsPage> createState() => _VolEventsPageState();
}

class _VolEventsPageState extends State<VolEventsPage> {
  String searchQuery = "";

  // Logic to check if event date has passed
  bool _isPastEvent(Timestamp timestamp) {
    final eventDate = timestamp.toDate();
    final today = DateTime.now();
    return eventDate.isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Subtle off-white background
      body: Column(
        children: [
          _buildTopSearchSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('event_date_timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                final docs =
                    snapshot.data?.docs.where((doc) {
                      final title =
                          doc['event_title']?.toString().toLowerCase() ?? "";
                      return title.contains(searchQuery.toLowerCase());
                    }).toList() ??
                    [];

                if (docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final String eventId = docs[index].id;
                    final Timestamp? ts = data['event_date_timestamp'];
                    final bool isPast = ts != null ? _isPastEvent(ts) : false;

                    return _buildModernEventCard(
                      context,
                      eventId,
                      data,
                      isPast,
                      ts,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildTopSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Find Opportunities",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search by event name...",
              prefixIcon: const Icon(Icons.search, color: Colors.green),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODERN EVENT CARD ---
  Widget _buildModernEventCard(
    BuildContext context,
    String id,
    Map data,
    bool isPast,
    Timestamp? ts,
  ) {
    String day = ts != null ? DateFormat('dd').format(ts.toDate()) : "--";
    String month = ts != null
        ? DateFormat('MMM').format(ts.toDate()).toUpperCase()
        : "TBD";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Stack(
              children: [
                // Image with Greyscale for past events
                ColorFiltered(
                  colorFilter: isPast
                      ? const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        )
                      : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        ),
                  child:
                      data['image'] != null &&
                          data['image'].toString().isNotEmpty
                      ? Image.memory(
                          base64Decode(data['image']),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
                // Date Badge Overlay
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          month,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Status Tag
                Positioned(top: 15, right: 15, child: _buildStatusTag(isPast)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['event_title'] ?? "Community Event",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: isPast ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          data['location'] ?? "Main Center",
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ReadMoreText(
                    data['description'] ?? "Join us for this impactful event.",
                    trimLines: 2,
                    colorClickableText: Colors.green,
                    style: TextStyle(color: Colors.grey[800], height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  if (!isPast)
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: [Colors.green, Color(0xFF2E7D32)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () => _showJoinRequestDialog(
                          context,
                          id,
                          data['event_title'] ?? "Event",
                        ),
                        child: const Text(
                          "Join This Cause",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(bool isPast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPast ? Colors.black87 : Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isPast ? "COMPLETED" : "ACTIVE",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No events match your search",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- JOIN REQUEST DIALOG ---
  void _showJoinRequestDialog(
    BuildContext context,
    String eventId,
    String eventTitle,
  ) {
    final TextEditingController skillController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Volunteer for $eventTitle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Share the skills you can bring to this event (e.g. Teaching, Logistics, Media).",
            ),
            const SizedBox(height: 15),
            TextField(
              controller: skillController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter your skills here...",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Maybe Later"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null && skillController.text.trim().isNotEmpty) {
                String customDocId = "${eventId}_$uid";
                await FirebaseFirestore.instance
                    .collection('volunteer_requests')
                    .doc(customDocId)
                    .set({
                      'event_id': eventId,
                      'event_title': eventTitle,
                      'volunteer_id': uid,
                      'skills': skillController.text.trim(),
                      'status': 'pending',
                      'requested_at': Timestamp.now(),
                    });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Application Sent! Tracking in 'Requests'"),
                  ),
                );
              }
            },
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
