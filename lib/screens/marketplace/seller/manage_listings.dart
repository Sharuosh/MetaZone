// File: lib/screens/marketplace/seller/manage_listings.dart
// MetaZone — Manage AR Listings (Creator Control Center)

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'upload_item.dart';

class ManageListingsScreen extends StatefulWidget {
  const ManageListingsScreen({super.key});

  @override
  State<ManageListingsScreen> createState() => _ManageListingsScreenState();
}

class _ManageListingsScreenState extends State<ManageListingsScreen> {
  // Demo data
  List<Map<String, dynamic>> _items = [
    {
      "id": "p1",
      "title": "Sci-Fi Portal",
      "price": 25.0,
      "active": true,
      "image": null,
      "views": 1280,
      "sales": 43,
      "rating": 4.6,
      "model": "portal.glb",
    },
    {
      "id": "p2",
      "title": "Hologram Sphere",
      "price": 15.0,
      "active": true,
      "image": null,
      "views": 850,
      "sales": 19,
      "rating": 4.2,
      "model": "sphere.glb",
    },
    {
      "id": "p3",
      "title": "AR Light Beam Pack",
      "price": 8.0,
      "active": false,
      "image": null,
      "views": 430,
      "sales": 9,
      "rating": 3.9,
      "model": "beam.usdz",
    },
  ];

  void _toggleActive(Map item) {
    setState(() => item["active"] = !item["active"]);
  }

  void _deleteItem(Map item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Delete Item", style: AppTextStyles.title()),
        content: Text("Are you sure you want to delete \"${item["title"]}\"?",
            style: AppTextStyles.body()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _items.removeWhere((e) => e["id"] == item["id"]));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Item deleted")),
              );
            },
            child: Text("Delete", style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(Map item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Manage: ${item["title"]}", style: AppTextStyles.title()),
          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Details"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadARItemScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.view_in_ar),
            title: const Text("Update AR Model"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Model update — Coming soon")),
              );
            },
          ),

          SwitchListTile(
            title: const Text("Active Listing"),
            value: item["active"],
            onChanged: (v) {
              Navigator.pop(context);
              _toggleActive(item);
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text("Delete Item", style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              _deleteItem(item);
            },
          ),
        ]),
      ),
    );
  }

  Widget _listingCard(Map item) {
    return GestureDetector(
      onTap: () => _openEditSheet(item),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item["active"]
                ? AppColors.primary.withOpacity(.25)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      image: item["image"] != null
                          ? DecorationImage(
                          image: FileImage(item["image"]),
                          fit: BoxFit.cover)
                          : null,
                    ),
                    child: item["image"] == null
                        ? Center(
                      child: Icon(Icons.image_outlined,
                          size: 42, color: AppColors.textSoft),
                    )
                        : null,
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Icon(Icons.view_in_ar,
                        size: 22,
                        color: AppColors.primary.withOpacity(.85)),
                  ),
                  if (!item["active"])
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(.7),
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12)),
                        ),
                        child: Text("Disabled",
                            style: AppTextStyles.caption(color: Colors.white)),
                      ),
                    )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item["title"], style: AppTextStyles.title(size: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 16, color: Colors.amber.shade300),
                        const SizedBox(width: 4),
                        Text(item["rating"].toString(),
                            style: AppTextStyles.caption()),
                        const Spacer(),
                        Text("\$${item["price"]}",
                            style: AppTextStyles.body()),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text("${item["views"]} views",
                            style: AppTextStyles.caption(size: 11)),
                        const SizedBox(width: 12),
                        Text("${item["sales"]} sold",
                            style: AppTextStyles.caption(size: 11)),
                      ],
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Manage Listings", style: AppTextStyles.heading()),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UploadARItemScreen()));
            },
            icon: const Icon(Icons.add_box_outlined),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: .74,
        ),
        itemCount: _items.length,
        itemBuilder: (_, i) => _listingCard(_items[i]),
      ),
    );
  }
}
