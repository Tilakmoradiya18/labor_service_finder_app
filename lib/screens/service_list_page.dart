import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_profile.dart';
import 'customer_worker_detail_pages.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key, required this.service});

  final String service;

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  String? filterArea;
  String? filterCity;
  double? filterRating;

  // Helper: parse Firestore document to WorkerProfile
  WorkerProfile _toProfile(Map<String, dynamic> data) {
    DateTime parseDob(dynamic v) {
      if (v == null) return DateTime(2000, 1, 1);
      if (v is Timestamp) return v.toDate();
      if (v is String) {
        // Try ISO-8601
        try { return DateTime.parse(v); } catch (_) {}
      }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () => Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: _openFilter,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .where('service', isEqualTo: widget.service)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load workers'));
          }
          final docs = snapshot.data?.docs ?? [];
          // Map to items and apply client-side filters (area, city, rating)
          final items = docs.map((d) {
            final p = _toProfile(d.data());
            return {'id': d.id, 'p': p};
          }).where((it) {
            final WorkerProfile w = it['p'] as WorkerProfile;
            final okArea = filterArea == null || filterArea!.isEmpty || w.area.toLowerCase().contains(filterArea!.toLowerCase());
            final okCity = filterCity == null || filterCity!.isEmpty || w.city.toLowerCase().contains(filterCity!.toLowerCase());
            final okRating = filterRating == null || w.rating >= filterRating!;
            return okArea && okCity && okRating;
          }).toList();

          if (items.isEmpty) {
            return const Center(child: Text('No workers found. Try adjusting filters.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final it = items[index];
              final String docId = it['id'] as String;
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
                                    Chip(label: Text(w.service)),
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
                          const Text('Rate: '),
                          for (int i = 1; i <= 5; i++)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              iconSize: 22,
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('workers')
                                      .doc(docId)
                                      .update({
                                    'rating': i.toDouble(),
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update rating')));
                                }
                              },
                              icon: Icon(
                                i <= w.rating.round()
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: Colors.amber,
                              ),
                              tooltip: '$i',
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
      ),
    );
  }

  void _openFilter() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final areaController = TextEditingController(text: filterArea);
        final cityController = TextEditingController(text: filterCity);
        double tempRating = filterRating ?? 0;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Filter', style: TextStyle(fontWeight: FontWeight.w600))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(labelText: 'Area'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Min Rating'),
                  Expanded(
                    child: Slider(
                      value: tempRating,
                      onChanged: (v) {
                        tempRating = v;
                        (context as Element).markNeedsBuild();
                      },
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: tempRating.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    filterArea = areaController.text.trim();
                    filterCity = cityController.text.trim();
                    filterRating = tempRating == 0 ? null : tempRating;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}


