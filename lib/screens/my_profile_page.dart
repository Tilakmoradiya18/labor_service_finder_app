import 'package:flutter/material.dart';
import '../models.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key, required this.state, required this.onView, required this.onUpdate, required this.onLogout});

  final AppState state;
  final VoidCallback onView;
  final VoidCallback onUpdate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final isWorker = state.currentRole == UserRole.worker;
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _TileButton(icon: Icons.visibility_outlined, label: 'View Profile', onTap: onView),
              const SizedBox(height: 12),
              _TileButton(icon: Icons.edit_outlined, label: 'Update', onTap: onUpdate),
              const SizedBox(height: 12),
              if (isWorker) ...[
                _TileButton(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Get Premium',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Premium'),
                        content: const Text('Premium boosts your visibility. (UI only)'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
              _TileButton(icon: Icons.logout, label: 'Logout', onTap: onLogout, color: Colors.red.shade50, textColor: Colors.red),
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


