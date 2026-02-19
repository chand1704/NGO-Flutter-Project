import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminCategoryScreen extends StatelessWidget {
  const AdminCategoryScreen({super.key});

  // --- IMAGE PICKER UTILITY ---
  Future<String?> _pickAndConvertImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 35,
    );

    if (image != null) {
      return base64Encode(await File(image.path).readAsBytes());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_category_fab',
        backgroundColor: Colors.green[700],
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(
          Icons.add_photo_alternate_rounded,
          color: Colors.white,
        ),
        label: const Text(
          "Add Category",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('donation_categories')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text("No categories found.")),
                );
              }

              final categories = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var data = categories[index].data() as Map<String, dynamic>;
                    return _buildCategoryCard(
                      context,
                      categories[index].id,
                      data,
                    );
                  }, childCount: categories.length),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Donation Portfolio",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "Manage your categories and items",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    String? base64String = data['image'];
    List items = data['items'] as List? ?? [];

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
      child: Column(
        children: [
          // Header with Image
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  color: Colors.grey[200],
                ),
                child: base64String != null && base64String.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.memory(
                          base64Decode(base64String),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.category_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    _circleActionBtn(
                      Icons.edit,
                      Colors.blue,
                      () => _showEditCategoryDialog(
                        context,
                        docId,
                        data['category_name'],
                        base64String,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _circleActionBtn(
                      Icons.delete,
                      Colors.red,
                      () => _deleteCategory(docId, data['category_name']),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    data['category_name'].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Items Expansion Area
          ExpansionTile(
            shape: const Border(),
            title: Text(
              "${items.length} Items Available",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              ...items.map(
                (item) => ListTile(
                  leading: const Icon(
                    Icons.label_important_outline,
                    color: Colors.green,
                  ),
                  title: Text(
                    item['title'] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    item['amount'] ?? "",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_note_rounded,
                          color: Colors.blue,
                        ),
                        onPressed: () =>
                            _showEditItemDialog(context, docId, item),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteItemConfirmation(docId, item),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton.icon(
                  onPressed: () => _showAddItemDialog(context, docId),
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  label: const Text(
                    "Add New Item",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // --- REFINED DIALOGS ---

  void _showAddCategoryDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    String? localBase64;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create Category",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  String? img = await _pickAndConvertImage();
                  if (img != null) setState(() => localBase64 = img);
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: localBase64 == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40),
                            Text("Upload Image"),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            base64Decode(localBase64!),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('donation_categories')
                          .add({
                            'category_name': nameController.text.trim(),
                            'image': localBase64 ?? "",
                            'items': [],
                          });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Save Category",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Use similar style for EditCategory, AddItem, and EditItem dialogs...
  // The logic remains the same as your previous code but with ModalBottomSheet and styled TextFields.

  void _deleteCategory(String id, String name) {
    Get.defaultDialog(
      title: "Delete Portfolio",
      middleText: "Are you sure you want to remove $name and all its contents?",
      textConfirm: "Remove",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await FirebaseFirestore.instance
            .collection('donation_categories')
            .doc(id)
            .delete();
        Get.back();
      },
    );
  }

  // --- ITEM LOGIC (Keeping your existing robust logic) ---
  // [Paste your _showAddItemDialog, _showEditItemDialog, _deleteItemConfirmation methods here]
  // Update their UI to match the ModalBottomSheet style used in _showAddCategoryDialog for consistency.

  void _showAddItemDialog(BuildContext context, String docId) {
    TextEditingController titleController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add New Item",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Item Name",
                prefixIcon: Icon(Icons.shopping_bag),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Suggested Amount",
                prefixText: "₹ ",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('donation_categories')
                      .doc(docId)
                      .update({
                        'items': FieldValue.arrayUnion([
                          {
                            'title': titleController.text,
                            'amount': "₹${amountController.text}",
                          },
                        ]),
                      });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Add to List",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, String docId, Map oldItem) {
    TextEditingController titleController = TextEditingController(
      text: oldItem['title'],
    );
    TextEditingController amountController = TextEditingController(
      text: oldItem['amount'].toString().replaceAll('₹', ''),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit Item",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Item Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "₹ ",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('donation_categories')
                    .doc(docId)
                    .update({
                      'items': FieldValue.arrayRemove([oldItem]),
                    });
                await FirebaseFirestore.instance
                    .collection('donation_categories')
                    .doc(docId)
                    .update({
                      'items': FieldValue.arrayUnion([
                        {
                          'title': titleController.text,
                          'amount': "₹${amountController.text}",
                        },
                      ]),
                    });
                Navigator.pop(context);
              },
              child: const Text("Update Item"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _deleteItemConfirmation(String docId, Map item) {
    Get.defaultDialog(
      title: "Remove Item",
      middleText: "Remove ${item['title']} from this category?",
      textConfirm: "Remove",
      buttonColor: Colors.red,
      onConfirm: () async {
        await FirebaseFirestore.instance
            .collection('donation_categories')
            .doc(docId)
            .update({
              'items': FieldValue.arrayRemove([item]),
            });
        Get.back();
      },
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    String docId,
    String currentName,
    String? currentImg,
  ) {
    TextEditingController editController = TextEditingController(
      text: currentName,
    );
    String? localBase64 = currentImg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: editController,
                decoration: const InputDecoration(labelText: "Category Name"),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  String? img = await _pickAndConvertImage();
                  if (img != null) setState(() => localBase64 = img);
                },
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: localBase64 == null
                      ? const Icon(Icons.add_a_photo)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            base64Decode(localBase64!),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('donation_categories')
                      .doc(docId)
                      .update({
                        'category_name': editController.text.trim(),
                        'image': localBase64 ?? "",
                      });
                  Navigator.pop(context);
                },
                child: const Text("Update Category"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
