import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/worker_profile.dart';

class WorkerProfileSetupPage extends StatefulWidget {
  const WorkerProfileSetupPage({super.key, required this.onSubmit, this.initial});

  final void Function(WorkerProfile) onSubmit;
  final WorkerProfile? initial;

  @override
  State<WorkerProfileSetupPage> createState() => _WorkerProfileSetupPageState();
}

class _WorkerProfileSetupPageState extends State<WorkerProfileSetupPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  DateTime? dob;
  final List<String> services = const [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'AC Repair',
    'Gardener',
    'House Cleaning',
    'Mechanic',
    'CCTV Installation',
    'Pest Control',
    'House Shifting',
    'Cook',
    'Driver',
    'Computer Repair',
    'Beautician',
    'Roofer',
    'Welder',
    'Mason',
  ];
  String? selectedService;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      fullNameController.text = i.fullName;
      phoneController.text = i.phone;
      addressController.text = i.address;
      areaController.text = i.area;
      cityController.text = i.city;
      selectedService = i.service;
      experienceController.text = i.experienceYears.toString();
      dob = i.dob;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Profile Setup')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _DobPicker(
                  value: dob,
                  onChanged: (d) => setState(() => dob = d),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: areaController,
                        decoration: const InputDecoration(labelText: 'Area'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: cityController,
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedService,
                  decoration: const InputDecoration(labelText: 'Service'),
                  items: services
                      .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedService = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(labelText: 'Experience (years)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          final years = int.tryParse(experienceController.text.trim()) ?? 0;
                          if (dob == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select DOB')));
                            return;
                          }
                          if (selectedService == null || selectedService!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a service')));
                            return;
                          }
                          setState(() => _saving = true);
                          final profile = WorkerProfile(
                            fullName: fullNameController.text.trim(),
                            phone: phoneController.text.trim(),
                            dob: dob!,
                            address: addressController.text.trim(),
                            area: areaController.text.trim(),
                            city: cityController.text.trim(),
                            service: selectedService!,
                            experienceYears: years,
                            available: true,
                          );
                          try {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid != null) {
                              await FirebaseFirestore.instance.collection('workers').doc(uid).set({
                                'fullName': profile.fullName,
                                'phone': profile.phone,
                                'dob': profile.dob.toIso8601String(),
                                'address': profile.address,
                                'area': profile.area,
                                'city': profile.city,
                                'service': profile.service,
                                'experienceYears': profile.experienceYears,
                                'rating': profile.rating,
                                'ratingCount': FieldValue.increment(0),
                                'available': profile.available,
                                'updatedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                            }
                            if (!mounted) return;
                            widget.onSubmit(profile);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save profile')));
                            }
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                  child: _saving
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save & Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DobPicker extends StatelessWidget {
  const _DobPicker({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(now.year - 80),
          lastDate: DateTime(now.year + 1),
          initialDate: value ?? DateTime(now.year - 20, now.month, now.day),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Date of Birth'),
        child: Text(
          value == null ? 'Select date' : '${value!.day}/${value!.month}/${value!.year}',
        ),
      ),
    );
  }
}


