import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state.dart';
import 'premium_checkout_page.dart';

class PremiumPlansPage extends StatefulWidget {
  const PremiumPlansPage({super.key, required this.state});

  final AppState state;

  @override
  State<PremiumPlansPage> createState() => _PremiumPlansPageState();
}

class _PremiumPlansPageState extends State<PremiumPlansPage> {
  bool _processing = false;

  Future<void> _activate(Duration duration) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _processing = true);
    try {
      final until = DateTime.now().add(duration);
      await FirebaseFirestore.instance.collection('workers').doc(uid).update({
        'premium': true,
        'premiumUntil': until.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      widget.state.workerProfile?.premium = true;
      widget.state.workerProfile?.premiumUntil = until;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium activated')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to activate premium')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Plans')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Choose a plan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _BigPlanCard(
              title: '1 Month',
              price: '₹99',
              icon: Icons.calendar_view_month,
              perks: const ['Priority listing', 'Premium badge', 'Support'],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PremiumCheckoutPage(
                    state: widget.state,
                    planTitle: '1 Month',
                    price: '₹99',
                    duration: const Duration(days: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BigPlanCard(
              title: '6 Months',
              price: '₹499',
              icon: Icons.calendar_today,
              perks: const ['Priority listing', 'Premium badge', 'Email support'],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PremiumCheckoutPage(
                    state: widget.state,
                    planTitle: '6 Months',
                    price: '₹499',
                    duration: const Duration(days: 180),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BigPlanCard(
              title: '1 Year',
              price: '₹899',
              icon: Icons.event_available,
              perks: const ['Top priority listing', 'Premium badge', 'Priority support'],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PremiumCheckoutPage(
                    state: widget.state,
                    planTitle: '1 Year',
                    price: '₹899',
                    duration: const Duration(days: 365),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (widget.state.workerProfile?.premium == true && widget.state.workerProfile?.premiumUntil != null) ...[
              Text(
                'Premium active until: '
                '${widget.state.workerProfile!.premiumUntil!.day}/'
                '${widget.state.workerProfile!.premiumUntil!.month}/'
                '${widget.state.workerProfile!.premiumUntil!.year}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              if (widget.state.workerProfile?.premiumPlan != null)
                Text(
                  'Current plan: ${widget.state.workerProfile!.premiumPlan!}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
            if (_processing) const SizedBox(height: 16),
            if (_processing) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class _BigPlanCard extends StatelessWidget {
  const _BigPlanCard({
    required this.title,
    required this.price,
    required this.icon,
    required this.perks,
    required this.onTap,
  });

  final String title;
  final String price;
  final IconData icon;
  final List<String> perks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                        Text(price, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: -6,
                      children: perks.map((p) => Chip(label: Text(p))).toList(),
                    ),
                    const SizedBox(height: 4),
                    const Text('Tap to continue', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Old custom card replaced by simpler ListTiles for reliability across devices
