import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'Admin_Event_Requests.dart';

class AdminEventScreen extends StatefulWidget {
  const AdminEventScreen({super.key});

  @override
  State<AdminEventScreen> createState() => _AdminEventScreenState();
}

class _AdminEventScreenState extends State<AdminEventScreen> {
  // --- IMAGE PICKER UTILITY ---
  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    if (image != null) {
      return base64Encode(await File(image.path).readAsBytes());
    }
    return null;
  }

  // --- LOGIC: BLUR ONLY ON THE DAY AFTER ---
  bool _isPastEvent(dynamic dateData) {
    if (dateData == null) return false;
    DateTime eventDate;
    if (dateData is Timestamp) {
      eventDate = dateData.toDate();
    } else {
      try {
        eventDate = DateFormat("dd MMM yyyy").parse(dateData.toString());
      } catch (_) {
        return false;
      }
    }
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    // Jan 28 remains Active; Jan 29 becomes Past
    return eventDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('event_date_timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );

          final docs = snapshot.data!.docs;
          int activeCount = docs
              .where((doc) => !_isPastEvent(doc['event_date_timestamp']))
              .length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. DASHBOARD HEADER
              SliverToBoxAdapter(
                child: _buildDashboardHeader(docs.length, activeCount),
              ),

              // 2. EVENTS LIST
              docs.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text("No events found.")),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final docId = docs[index].id;
                          final bool isPast = _isPastEvent(
                            data['event_date_timestamp'],
                          );
                          return _buildModernEventCard(docId, data, isPast);
                        }, childCount: docs.length),
                      ),
                    ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[700],
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Create Event",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddEventDialog(context),
      ),
    );
  }

  Widget _buildDashboardHeader(int total, int active) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        40,
        20,
        40,
      ), // Increased vertical padding for better focus
      decoration: BoxDecoration(),

      child: Row(
        children: [
          // 1. TOTAL PORTFOLIO CARD
          _headerStatCard(
            "Total Portfolio",
            "$total",
            Icons.inventory_2_outlined,
            Colors.blueAccent,
          ),

          const SizedBox(width: 15),

          // 2. CURRENTLY ACTIVE CARD
          _headerStatCard(
            "Currently Active",
            "$active",
            Icons.sensors_rounded,
            Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  // Updated helper to support custom accent colors for the icons
  Widget _headerStatCard(
    String title,
    String count,
    IconData icon,
    Color accentColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.green[800], // Glassmorphism effect
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accentColor, size: 28),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI: MODERN EVENT CARD ---
  Widget _buildModernEventCard(
    String docId,
    Map<String, dynamic> data,
    bool isPast,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Opacity(
          opacity: isPast ? 0.65 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHeader(data['image'], isPast),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['event_title'] ?? "Unnamed Event",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: isPast
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        _buildActionButtons(docId, data, isPast),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['location'] ?? "NGO Center",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Icon(
                          Icons.calendar_month,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['date'] ?? "",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminEventRequests(
                            eventId: docId,
                            eventTitle: data['event_title'],
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Manage Volunteers & Requests",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.green,
                          ),
                        ],
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

  Widget _buildImageHeader(String? img, bool isPast) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: isPast
              ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
          child: img != null && img.isNotEmpty
              ? Image.memory(
                  base64Decode(img),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey, size: 50),
                ),
        ),
        Positioned(top: 15, right: 15, child: _buildStatusBadge(isPast)),
      ],
    );
  }

  Widget _buildStatusBadge(bool isPast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPast ? Colors.black54 : Colors.green[600],
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

  Widget _buildActionButtons(
    String id,
    Map<String, dynamic> data,
    bool isPast,
  ) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.blue),
          onPressed: isPast
              ? null
              : () => _showEditEventDialog(context, id, data),
        ),
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
          onPressed: isPast ? null : () => _showDeleteConfirmation(id),
        ),
      ],
    );
  }

  // --- CRUD HELPERS ---

  void _showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text(
          "All volunteer data for this event will be permanently removed. Proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep Event"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('events')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text(
              "Delete Permanently",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final title = TextEditingController();
    final desc = TextEditingController();
    final loc = TextEditingController();
    final date = TextEditingController();
    DateTime? selectedDate;
    String? base64Image;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Create New Event",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    String? img = await _pickImage();
                    if (img != null) setState(() => base64Image = img);
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: base64Image == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40),
                              Text("Add Event Photo"),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(
                              base64Decode(base64Image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: "Event Title"),
                ),
                TextField(
                  controller: loc,
                  decoration: const InputDecoration(labelText: "Location"),
                ),
                TextField(
                  controller: date,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Event Date",
                    suffixIcon: Icon(Icons.event),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        date.text = DateFormat("dd MMM yyyy").format(picked);
                      });
                    }
                  },
                ),
                TextField(
                  controller: desc,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    if (title.text.isEmpty || selectedDate == null) return;
                    await FirebaseFirestore.instance.collection('events').add({
                      'event_title': title.text.trim(),
                      'description': desc.text.trim(),
                      'location': loc.text.trim(),
                      'date': date.text,
                      'event_date_timestamp': Timestamp.fromDate(selectedDate!),
                      'image': base64Image ?? "",
                      'created_at': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Publish Event",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditEventDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    // Implement similar UI to Add dialog but with existing values
    final title = TextEditingController(text: data['event_title']);
    final desc = TextEditingController(text: data['description']);
    final loc = TextEditingController(text: data['location']);
    final date = TextEditingController(text: data['date']);
    DateTime selectedDate = (data['event_date_timestamp'] as Timestamp)
        .toDate();
    String? base64Image = data['image'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Update Event Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () async {
                    String? img = await _pickImage();
                    if (img != null) setState(() => base64Image = img);
                  },
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: base64Image == null || base64Image == ""
                        ? const Icon(Icons.add_a_photo)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(
                              base64Decode(base64Image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: "Event Title"),
                ),
                TextField(
                  controller: loc,
                  decoration: const InputDecoration(labelText: "Location"),
                ),
                TextField(
                  controller: date,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Date",
                    suffixIcon: Icon(Icons.event),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        date.text = DateFormat("dd MMM yyyy").format(picked);
                      });
                    }
                  },
                ),
                TextField(
                  controller: desc,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('events')
                        .doc(docId)
                        .update({
                          'event_title': title.text.trim(),
                          'description': desc.text.trim(),
                          'location': loc.text.trim(),
                          'date': date.text,
                          'event_date_timestamp': Timestamp.fromDate(
                            selectedDate,
                          ),
                          'image': base64Image ?? "",
                          'updated_at': FieldValue.serverTimestamp(),
                        });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Save Updates",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
