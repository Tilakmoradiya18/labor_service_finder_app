import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.onSignedUp});

  final void Function(UserRole role) onSignedUp;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  UserRole role = UserRole.customer;
  bool isObscure = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Username is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => isObscure = !isObscure),
                      ),
                    ),
                    obscureText: isObscure,
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Role'),
                  const SizedBox(height: 8),
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(value: UserRole.customer, label: Text('Customer'), icon: Icon(Icons.person_outline)),
                      ButtonSegment(value: UserRole.worker, label: Text('Worker'), icon: Icon(Icons.handyman_outlined)),
                    ],
                    selected: {role},
                    onSelectionChanged: (s) => setState(() => role = s.first),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!(_formKey.currentState?.validate() ?? false)) return;
                            setState(() => _loading = true);
                            try {
                              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text,
                              );
                              if (!mounted) return;
                              widget.onSignedUp(role);
                            } on FirebaseAuthException catch (e) {
                              final msg = e.message ?? 'Signup failed';
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                              }
                            } catch (_) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signup failed')));
                              }
                            } finally {
                              if (mounted) setState(() => _loading = false);
                            }
                          },
                    child: _loading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


