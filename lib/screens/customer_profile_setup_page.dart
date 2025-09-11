import 'package:flutter/material.dart';
import '../models.dart';

class CustomerProfileSetupPage extends StatefulWidget {
  const CustomerProfileSetupPage({super.key, required this.onSubmit, this.initial});

  final void Function(CustomerProfile) onSubmit;
  final CustomerProfile? initial;

  @override
  State<CustomerProfileSetupPage> createState() => _CustomerProfileSetupPageState();
}

class _CustomerProfileSetupPageState extends State<CustomerProfileSetupPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  DateTime? dob;

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
      dob = i.dob;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile Setup')),
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
                TextField(
                  controller: areaController,
                  decoration: const InputDecoration(labelText: 'Area'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (dob == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select DOB')));
                      return;
                    }
                    widget.onSubmit(
                      CustomerProfile(
                        fullName: fullNameController.text.trim(),
                        phone: phoneController.text.trim(),
                        dob: dob!,
                        address: addressController.text.trim(),
                        area: areaController.text.trim(),
                        city: cityController.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Save & Continue'),
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


