import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'premium_plans_page.dart';
import 'favorites_page.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key, required this.state, required this.onView, required this.onUpdate, required this.onLogout});

  final AppState state;
  final VoidCallback onView;
  final VoidCallback onUpdate;
  final VoidCallback onLogout;

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late bool _available;

  @override
  void initState() {
    super.initState();
    _available = widget.state.workerProfile?.available ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isWorker = widget.state.currentRole == UserRole.worker;
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _TileButton(icon: Icons.visibility_outlined, label: 'View Profile', onTap: widget.onView),
              const SizedBox(height: 12),
              _TileButton(icon: Icons.edit_outlined, label: 'Update', onTap: widget.onUpdate),
              const SizedBox(height: 12),
              if (isWorker) ...[
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.toggle_on_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Available')),
                        Switch(
                          value: _available,
                          onChanged: (v) async {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;
                            try {
                              await FirebaseFirestore.instance.collection('workers').doc(uid).update({
                                'available': v,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });
                              // Update local and shared state only after successful write
                              setState(() => _available = v);
                              widget.state.workerProfile?.available = v;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(v ? 'Availability: ON' : 'Availability: OFF')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to update availability. Please try again.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _TileButton(
                  icon: Icons.workspace_premium_outlined,
                  label: widget.state.workerProfile?.premium == true
                      ? 'Premium Active'
                      : 'Get Premium',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PremiumPlansPage(state: widget.state),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
              _TileButton(
                icon: Icons.favorite_outline,
                label: 'Favorites',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FavoritesPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _TileButton(icon: Icons.logout, label: 'Logout', onTap: widget.onLogout, color: Colors.red.shade50, textColor: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  const _TileButton({required this.icon, required this.label, required this.onTap, this.color, this.textColor});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: textColor ?? Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: TextStyle(color: textColor ?? Colors.black))),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}


