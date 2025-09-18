import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLoggedIn, required this.onGoToSignup});

  final VoidCallback onLoggedIn;
  final VoidCallback onGoToSignup;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isObscure = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text('Login to continue', textAlign: TextAlign.center),
                    const SizedBox(height: 32),
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? false)) return;
                              setState(() => _loading = true);
                              final email = emailController.text.trim();
                              final pass = passwordController.text; // don't trim passwords
                              try {
                                await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
                                if (!mounted) return;
                                widget.onLoggedIn();
                              } on FirebaseAuthException catch (e) {
                                final code = e.code.toLowerCase();
                                String msg;
                                switch (code) {
                                  case 'invalid-credential':
                                  case 'wrong-password':
                                    msg = 'Incorrect email or password.';
                                    break;
                                  case 'user-not-found':
                                    msg = 'No account found for this email.';
                                    break;
                                  case 'invalid-email':
                                    msg = 'Enter a valid email address.';
                                    break;
                                  case 'too-many-requests':
                                    msg = 'Too many attempts. Try again later.';
                                    break;
                                  case 'user-disabled':
                                    msg = 'This account has been disabled.';
                                    break;
                                  default:
                                    msg = e.message ?? 'Login failed';
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                }
                              } catch (_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
                                }
                              } finally {
                                if (mounted) setState(() => _loading = false);
                              }
                            },
                      child: _loading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: widget.onGoToSignup,
                      child: const Text("Don't have an account? Sign up"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


