import 'package:flutter/material.dart';
import '../models.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.state, required this.onOpenMyProfile, required this.onOpenService});

  final AppState state;
  final void Function(BuildContext) onOpenMyProfile;
  final void Function(BuildContext, String) onOpenService;

  static const services = [
    'Electrician', 'Plumber', 'Painter', 'Carpenter', 'AC Repair', 'Gardener', 'Cleaning', 'Mechanic'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labor Service Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => onOpenMyProfile(context),
            tooltip: 'My Profile',
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for services or workers',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popular Services',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  itemCount: services.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemBuilder: (context, index) {
                    final s = services[index];
                    return _ServiceCard(
                      name: s,
                      onTap: () => onOpenService(context, s),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.handyman, color: Theme.of(context).colorScheme.primary),
              ),
              const Spacer(),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Tap to explore', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}


