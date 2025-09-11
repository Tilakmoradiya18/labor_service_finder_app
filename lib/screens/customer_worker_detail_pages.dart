import 'package:flutter/material.dart';
import '../models.dart';

class WorkerDetailPage extends StatelessWidget {
  const WorkerDetailPage({super.key, required this.profile});

  final WorkerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Profile')),
      body: p == null
          ? const Center(child: Text('No profile'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoRow(label: 'Name', value: p.fullName),
          _InfoRow(label: 'Phone', value: p.phone),
          _InfoRow(label: 'DOB', value: '${p.dob.day}/${p.dob.month}/${p.dob.year}'),
          _InfoRow(label: 'Address', value: p.address),
          _InfoRow(label: 'Area', value: p.area),
          _InfoRow(label: 'City', value: p.city),
          _InfoRow(label: 'Service', value: p.service),
          _InfoRow(label: 'Experience', value: '${p.experienceYears} years'),
          _InfoRow(label: 'Rating', value: p.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }
}

class CustomerDetailPage extends StatelessWidget {
  const CustomerDetailPage({super.key, required this.profile});

  final CustomerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile')),
      body: p == null
          ? const Center(child: Text('No profile'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoRow(label: 'Name', value: p.fullName),
          _InfoRow(label: 'Phone', value: p.phone),
          _InfoRow(label: 'DOB', value: '${p.dob.day}/${p.dob.month}/${p.dob.year}'),
          _InfoRow(label: 'Address', value: p.address),
          _InfoRow(label: 'Area', value: p.area),
          _InfoRow(label: 'City', value: p.city),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}


