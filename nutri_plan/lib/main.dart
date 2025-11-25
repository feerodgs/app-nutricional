import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/viewmodels/auth_viewmodel.dart';
import 'src/viewmodels/user_viewmodel.dart';
import 'src/views/auth/sign_in_view.dart';
import 'src/views/home/home_view.dart';

import 'src/onboarding/onboarding_flow.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'src/data/user_repository.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  final fcmToken = await messaging.getToken();
  debugPrint("FCM TOKEN: $fcmToken");

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    sslEnabled: true,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        home: const Root(),
      ),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snap) {
        final firebaseUser = snap.data;

        // Não logado → tela de login
        if (firebaseUser == null) {
          return const SignInView();
        }

        return FutureBuilder(
          future: _prepareUser(firebaseUser.uid, context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userVM = context.watch<UserViewModel>();
            final user = userVM.user;

            bool finishedOnboarding = false;
            if (user != null) {
              finishedOnboarding = user.finishedOnboarding;
            }

            return finishedOnboarding
                ? const HomeView(initialIndex: 0)
                : const OnboardingFlow();
          },
        );
      },
    );
  }

  Future<void> _prepareUser(String uid, BuildContext context) async {
    final userVM = context.read<UserViewModel>();

    if (userVM.user != null) return;

    final exists = await UserRepository.exists(uid);

    if (!exists) {
      await UserRepository.ensureUserDocument(
        FirebaseAuth.instance.currentUser!,
      );
    }

    await userVM.loadCurrent();
  }
}
