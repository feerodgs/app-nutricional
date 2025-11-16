import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'src/viewmodels/auth_viewmodel.dart';
import 'src/viewmodels/user_viewmodel.dart';
import 'src/views/auth/sign_in_view.dart';
import 'src/views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Root(),
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
        final localUser = snap.data;
        if (localUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UserViewModel>().loadCurrent();
          });
        }
        return localUser == null
            ? const SignInView()
            : const HomeView(initialIndex: 0);
      },
    );
  }
}
