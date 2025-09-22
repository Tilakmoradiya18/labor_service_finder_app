import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/worker_profile.dart';
import 'customer_worker_detail_pages.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  WorkerProfile _toProfile(Map<String, dynamic> data) {
    DateTime parseDob(dynamic v) {
      if (v == null) return DateTime(2000, 1, 1);
      if (v is Timestamp) return v.toDate();
      if (v is String) { try { return DateTime.parse(v); } catch (_) {} }
      return DateTime(2000, 1, 1);
    }
    double parseDouble(dynamic v, [double fallback = 0.0]) {
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }
    return WorkerProfile(
      fullName: (data['fullName'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      dob: parseDob(data['dob']),
      address: (data['address'] ?? '').toString(),
      area: (data['area'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      service: (data['service'] ?? '').toString(),
      experienceYears: (data['experienceYears'] is int)
          ? data['experienceYears'] as int
          : int.tryParse((data['experienceYears'] ?? '').toString()) ?? 0,
      rating: parseDouble(data['rating'], 0.0),
      available: (data['available'] is bool) ? data['available'] as bool : true,
      premium: (data['premium'] is bool) ? data['premium'] as bool : false,
      premiumUntil: parseDob(data['premiumUntil']),
      // premiumPlan not needed for card here
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: uid == null
          ? const Center(child: Text('Please log in to view favorites'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('workers').doc(uid).snapshots(),
              builder: (context, roleSnap) {
                final isWorkerUser = roleSnap.data?.exists == true;
                final favColl = FirebaseFirestore.instance
                    .collection(isWorkerUser ? 'workers' : 'customers')
                    .doc(uid)
                    .collection('favorites');
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: favColl.snapshots(),
                  builder: (context, favSnap) {
                    if (favSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final favIds = (favSnap.data?.docs ?? []).map((d) => d.id).toList();
                    if (favIds.isEmpty) {
                      return const Center(child: Text('No favorites yet'));
                    }
                    final limited = favIds.length > 10 ? favIds.sublist(0, 10) : favIds;
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('workers')
                          .where(FieldPath.documentId, whereIn: limited)
                          .snapshots(),
                      builder: (context, workersSnap) {
                        if (workersSnap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final docs = workersSnap.data?.docs ?? [];
                        final items = docs.map((d) => {'id': d.id, 'p': _toProfile(d.data())}).toList();
                        if (items.isEmpty) return const Center(child: Text('No favorites to show'));
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final it = items[index];
                            final WorkerProfile w = it['p'] as WorkerProfile;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          child: const Icon(Icons.person, color: Colors.black87),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(w.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: -8,
                                                children: [
                                                  Chip(label: Text(w.city)),
                                                  Chip(label: Text('${w.experienceYears} yrs')),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.amber, size: 16),
                                              const SizedBox(width: 4),
                                              Text(w.rating.toStringAsFixed(1)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => WorkerDetailPage(profile: w),
                                                ),
                                              );
                                            },
                                            child: const Text('View Profile'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.surfaceVariant,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Theme.of(context).dividerColor),
                                            ),
                                            child: Text(
                                              w.phone,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
