import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/app_state.dart';
import 'models/user_role.dart';
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

  void _openMyProfile(BuildContext context) {
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
