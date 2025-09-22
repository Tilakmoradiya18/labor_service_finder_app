import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/app_state.dart';
import 'models/user_role.dart';
import 'models/customer_profile.dart';
import 'models/worker_profile.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'screens/my_profile_page.dart';
import 'screens/customer_profile_setup_page.dart';
import 'screens/worker_profile_setup_page.dart';
import 'screens/customer_worker_detail_pages.dart';
import 'screens/service_list_page.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // On Android, reads config from google-services.json
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState state = AppState();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  DateTime _parseDob(dynamic v) {
    if (v == null) return DateTime(2000, 1, 1);
    if (v is Timestamp) return v.toDate();
    if (v is String) {
      try { return DateTime.parse(v); } catch (_) {}
    }
    return DateTime(2000, 1, 1);
  }

  double _parseDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  Future<void> _loadUserProfileAndRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final workersRef = FirebaseFirestore.instance.collection('workers').doc(uid);
      final customersRef = FirebaseFirestore.instance.collection('customers').doc(uid);
      final results = await Future.wait([workersRef.get(), customersRef.get()]);
      final workerSnap = results[0];
      final customerSnap = results[1];

      if (workerSnap.exists) {
        final data = workerSnap.data() as Map<String, dynamic>;
        state.currentRole = UserRole.worker;
        state.workerProfile = WorkerProfile(
          fullName: (data['fullName'] ?? '').toString(),
          phone: (data['phone'] ?? '').toString(),
          dob: _parseDob(data['dob']),
          address: (data['address'] ?? '').toString(),
          area: (data['area'] ?? '').toString(),
          city: (data['city'] ?? '').toString(),
          service: (data['service'] ?? '').toString(),
          experienceYears: (data['experienceYears'] is int)
              ? data['experienceYears'] as int
              : int.tryParse((data['experienceYears'] ?? '').toString()) ?? 0,
          rating: _parseDouble(data['rating'], 0.0),
          available: (data['available'] is bool) ? data['available'] as bool : true,
          premium: (data['premium'] is bool) ? data['premium'] as bool : false,
          premiumUntil: _parseDob(data['premiumUntil']),
          premiumPlan: (data['premiumPlan'] ?? '') == '' ? null : (data['premiumPlan'] as String),
        );
        state.customerProfile = null;
      } else if (customerSnap.exists) {
        final data = customerSnap.data() as Map<String, dynamic>;
        state.currentRole = UserRole.customer;
        state.customerProfile = CustomerProfile(
          fullName: (data['fullName'] ?? '').toString(),
          phone: (data['phone'] ?? '').toString(),
          dob: _parseDob(data['dob']),
          address: (data['address'] ?? '').toString(),
          area: (data['area'] ?? '').toString(),
          city: (data['city'] ?? '').toString(),
        );
        state.workerProfile = null;
      } else {
        // No profile documents found; keep current state (likely nulls)
      }
      if (mounted) setState(() {});
    } catch (_) {
      // Swallow errors for now; could add a snackbar if desired
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Labor Service Finder',
      navigatorKey: navigatorKey,
      theme: AppTheme.light,
      home: LoginPage(
        onLoggedIn: () {
          state.currentRole ??= UserRole.customer;
          navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomePage(
                state: state,
                onOpenMyProfile: _openMyProfile,
                onOpenService: _openService,
              ),
            ),
          );
        },
        onGoToSignup: () {
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (_) => SignupPage(
                onSignedUp: (role) {
                  state.currentRole = role;
                  if (role == UserRole.customer) {
                    navigatorKey.currentState!.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => CustomerProfileSetupPage(
                          initial: state.customerProfile,
                          onSubmit: (profile) {
                            state.customerProfile = profile;
                            navigatorKey.currentState!.pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => HomePage(
                                  state: state,
                                  onOpenMyProfile: _openMyProfile,
                                  onOpenService: _openService,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    navigatorKey.currentState!.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => WorkerProfileSetupPage(
                          initial: state.workerProfile,
                          onSubmit: (profile) {
                            state.workerProfile = profile;
                            navigatorKey.currentState!.pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => HomePage(
                                  state: state,
                                  onOpenMyProfile: _openMyProfile,
                                  onOpenService: _openService,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _openMyProfile(BuildContext context) async {
    // Ensure we load the latest profile/role from Firestore after login or role changes
    await _loadUserProfileAndRole();
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => MyProfilePage(
          state: state,
          onView: () {
            if (state.currentRole == UserRole.worker) {
              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (_) => WorkerDetailPage(profile: state.workerProfile),
                ),
              );
            } else {
              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (_) => CustomerDetailPage(profile: state.customerProfile),
                ),
              );
            }
          },
          onUpdate: () {
            if (state.currentRole == UserRole.worker) {
              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (_) => WorkerProfileSetupPage(
                    initial: state.workerProfile,
                    onSubmit: (p) {
                      state.workerProfile = p;
                      navigatorKey.currentState!.pop();
                      setState(() {});
                    },
                  ),
                ),
              );
            } else {
              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (_) => CustomerProfileSetupPage(
                    initial: state.customerProfile,
                    onSubmit: (p) {
                      state.customerProfile = p;
                      navigatorKey.currentState!.pop();
                      setState(() {});
                    },
                  ),
                ),
              );
            }
          },
          onLogout: () async {
            try {
              await FirebaseAuth.instance.signOut();
            } catch (_) {}
            setState(() {
              state.currentRole = null;
              state.customerProfile = null;
              state.workerProfile = null;
            });
            navigatorKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => LoginPage(
                  onLoggedIn: () {
                    navigatorKey.currentState!.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          state: state,
                          onOpenMyProfile: _openMyProfile,
                          onOpenService: _openService,
                        ),
                      ),
                    );
                  },
                  onGoToSignup: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (_) => SignupPage(
                          onSignedUp: (role) {
                            state.currentRole = role;
                            if (role == UserRole.customer) {
                              navigatorKey.currentState!.pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => CustomerProfileSetupPage(
                                    initial: state.customerProfile,
                                    onSubmit: (profile) {
                                      state.customerProfile = profile;
                                      navigatorKey.currentState!.pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => HomePage(
                                            state: state,
                                            onOpenMyProfile: _openMyProfile,
                                            onOpenService: _openService,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            } else {
                              navigatorKey.currentState!.pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => WorkerProfileSetupPage(
                                    initial: state.workerProfile,
                                    onSubmit: (profile) {
                                      state.workerProfile = profile;
                                      navigatorKey.currentState!.pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => HomePage(
                                            state: state,
                                            onOpenMyProfile: _openMyProfile,
                                            onOpenService: _openService,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
                  (route) => false,
            );
          },
        ),
      ),
    );
  }

  void _openService(BuildContext context, String service) {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => ServiceListPage(service: service),
      ),
    );
  }
}
