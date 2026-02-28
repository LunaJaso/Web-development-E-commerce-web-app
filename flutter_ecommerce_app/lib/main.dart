import 'package:flutter/material.dart';
import 'pages/mainShell.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

Future<void> main() async {
  // Intilizes flutter before any other code runs
  WidgetsFlutterBinding.ensureInitialized();

// initilizes firebase befor eanything else runs
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// If no user is currently signed in, sign in anonymously
  if (FirebaseAuth.instance.currentUser == null) {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('Anonymous user signed in');
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
    }
  }

// Runs the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

// If the user is not signed in, show a signing in message
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: Text('Signing in…')),
            );
          }

          return const MainShell();
        },
      ),
    );
  }
}
