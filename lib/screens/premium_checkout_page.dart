import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state.dart';

class PremiumCheckoutPage extends StatefulWidget {
  const PremiumCheckoutPage({
    super.key,
    required this.state,
    required this.planTitle,
    required this.price,
    required this.duration,
  });

  final AppState state;
  final String planTitle;
  final String price;
  final Duration duration;

  @override
  State<PremiumCheckoutPage> createState() => _PremiumCheckoutPageState();
}

class _PremiumCheckoutPageState extends State<PremiumCheckoutPage> {
  final nameController = TextEditingController();
  final cardController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  bool _processing = false;

  Future<void> _completePayment() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay
    try {
      final until = DateTime.now().add(widget.duration);
      await FirebaseFirestore.instance.collection('workers').doc(uid).update({
        'premium': true,
        'premiumUntil': until.toIso8601String(),
        'premiumPlan': widget.planTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      widget.state.workerProfile?.premium = true;
      widget.state.workerProfile?.premiumUntil = until;
      widget.state.workerProfile?.premiumPlan = widget.planTitle;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Premium activated: ${widget.planTitle}')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.planTitle} • ${widget.price}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text('Enter dummy payment details to continue'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Card holder name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Card number'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: const InputDecoration(labelText: 'CVV'),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.lock),
                onPressed: _processing ? null : _completePayment,
                label: Text('Pay ${widget.price}'),
              ),
              if (_processing) const SizedBox(height: 16),
              if (_processing) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
