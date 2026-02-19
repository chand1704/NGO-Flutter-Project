import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class UserEvent extends StatelessWidget {
  const UserEvent({super.key});

  bool _isPastEvent(Timestamp timestamp) {
    final eventDate = timestamp.toDate();
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return eventDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC), // Premium neutral white
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('event_date_timestamp', descending: true)
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
          if (docs.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              110,
            ), // Padding for floating nav
            physics: const BouncingScrollPhysics(), // Premium elastic feel
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final bool isPast = data['event_date_timestamp'] != null
                  ? _isPastEvent(data['event_date_timestamp'])
                  : false;

              return _buildPremiumEventCard(context, data, isPast);
            },
          );
        },
      ),
    );
  }

  Widget _buildPremiumEventCard(
    BuildContext context,
    Map<String, dynamic> data,
    bool isPast,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isPast
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.green.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CINEMATIC IMAGE HEADER
              Stack(
                children: [
                  _buildEventImage(data['image'], isPast),
                  // Gradient for text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: _buildGlassStatusTag(isPast),
                  ),
                ],
              ),

              // 2. CONTENT AREA
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['event_title'] ?? "Community Outreach",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900, // Editorial boldness
                        letterSpacing: -0.6,
                        color: isPast ? Colors.grey.shade600 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.calendar_today_rounded,
                          data['date'] ??
                              DateFormat(
                                "dd MMM yyyy",
                              ).format(data['event_date_timestamp'].toDate()),
                        ),
                        const SizedBox(width: 15),
                        _buildInfoChip(
                          Icons.location_on_rounded,
                          data['location'] ?? "Main Center",
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    ReadMoreText(
                      data['description'] ?? "Join us in our next mission.",
                      trimLines: 3,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: ' Read more',
                      trimExpandedText: ' Less',
                      moreStyle: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                      lessStyle: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
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

  Widget _buildEventImage(String? base64, bool isPast) {
    return ColorFiltered(
      colorFilter: isPast
          ? const ColorFilter.mode(
              Colors.grey,
              BlendMode.saturation,
            ) // Greyscale for past
          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
      child: base64 != null && base64.isNotEmpty
          ? Image.memory(
              base64Decode(base64),
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 230,
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 50),
            ),
    );
  }

  Widget _buildGlassStatusTag(bool isPast) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glassmorphism
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isPast
                ? Colors.black45
                : Colors.green.withValues(alpha: 0.7),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            isPast ? "COMPLETED" : "UPCOMING",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.green.shade700),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Stay tuned for upcoming events!",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// import 'dart:convert';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:readmore/readmore.dart';
//
// class UserEvent extends StatelessWidget {
//   const UserEvent({super.key});
//
//   // 🔥 LOGIC TO CHECK IF EVENT DATE HAS PASSED
//   bool _isPastEvent(Timestamp timestamp) {
//     final eventDate = timestamp.toDate();
//     final today = DateTime(
//       DateTime.now().year,
//       DateTime.now().month,
//       DateTime.now().day,
//     );
//     return eventDate.isBefore(today);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('events')
//             .orderBy('event_date_timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Colors.green),
//             );
//           }
//
//           final docs = snapshot.data?.docs ?? [];
//           if (docs.isEmpty) {
//             return const Center(child: Text("No events available"));
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//
//               // 🔥 Determine if event is past
//               final bool isPast = data['event_date_timestamp'] != null
//                   ? _isPastEvent(data['event_date_timestamp'])
//                   : false;
//
//               return Card(
//                 elevation: isPast ? 1 : 4,
//                 margin: const EdgeInsets.only(bottom: 18),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Opacity(
//                   opacity: isPast ? 0.6 : 1.0, // 🔥 Dim past events
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // --- IMAGE SECTION WITH STATUS TAG ---
//                       Stack(
//                         children: [
//                           if (data['image'] != null &&
//                               data['image'].toString().isNotEmpty)
//                             ClipRRect(
//                               borderRadius: const BorderRadius.vertical(
//                                 top: Radius.circular(16),
//                               ),
//                               child: ColorFiltered(
//                                 // 🔥 Apply Greyscale if past
//                                 colorFilter: isPast
//                                     ? const ColorFilter.mode(
//                                         Colors.grey,
//                                         BlendMode.saturation,
//                                       )
//                                     : const ColorFilter.mode(
//                                         Colors.transparent,
//                                         BlendMode.multiply,
//                                       ),
//                                 child: Image.memory(
//                                   base64Decode(data['image']),
//                                   height: 200,
//                                   width: double.infinity,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             )
//                           else
//                             Container(
//                               height: 180,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 borderRadius: const BorderRadius.vertical(
//                                   top: Radius.circular(16),
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.image,
//                                 size: 50,
//                                 color: Colors.grey,
//                               ),
//                             ),
//
//                           // 🔥 THE STATUS TAG OVERLAY
//                           Positioned(
//                             top: 15,
//                             right: 15,
//                             child: _buildStatusTag(isPast),
//                           ),
//                         ],
//                       ),
//
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               data['event_title'] ?? "Untitled Event",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 decoration: isPast
//                                     ? TextDecoration.lineThrough
//                                     : null, // 🔥 Strike-through for past
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//
//                             // DATE & LOCATION INFO
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.calendar_today,
//                                   size: 14,
//                                   color: Colors.green,
//                                 ),
//                                 const SizedBox(width: 5),
//                                 Text(
//                                   data['date'] ??
//                                       DateFormat("dd MMM yyyy").format(
//                                         data['event_date_timestamp'].toDate(),
//                                       ),
//                                   style: TextStyle(color: Colors.grey[800]),
//                                 ),
//                                 const SizedBox(width: 15),
//                                 const Icon(
//                                   Icons.location_on,
//                                   size: 16,
//                                   color: Colors.green,
//                                 ),
//                                 const SizedBox(width: 5),
//                                 Expanded(
//                                   child: Text(
//                                     data['location'] ?? "NGO Site",
//                                     style: TextStyle(color: Colors.grey[700]),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//
//                             // 🔥 DESCRIPTION WITH SHOW MORE / LESS
//                             ReadMoreText(
//                               data['description'] ?? "No description available",
//                               trimLines: 3,
//                               trimMode: TrimMode.Line,
//                               trimCollapsedText: ' Show more',
//                               trimExpandedText: ' Show less',
//                               moreStyle: const TextStyle(
//                                 color: Colors.blue,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               lessStyle: const TextStyle(
//                                 color: Colors.blue,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   // --- COMPONENT: STATUS TAG BUILDER ---
//   Widget _buildStatusTag(bool isPast) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: isPast ? Colors.black54 : Colors.green.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         isPast ? "COMPLETED" : "ACTIVE",
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }
// }
