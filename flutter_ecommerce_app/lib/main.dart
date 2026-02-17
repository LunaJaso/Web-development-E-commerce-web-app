// Imports Flutter design materials
import 'package:flutter/material.dart';

// Imports mainShell.dart
import 'pages/mainShell.dart';

// Removed default demo content as it was flagging as unused
// Intial entry point for Flutter applications
void main() {
  // Starts appplication (MyApp)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App Name should probably be changed to someting like Eccommerce Application
      title: 'Flutter Demo',
      // Global theme data
      theme: ThemeData(
        // Generates a color scheme based on input color
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Enables Material Design 3 styling
        useMaterial3: true,
      ),
      // The first screen loaded for the user when launching application (contains navigation bar)
      home: const MainShell(),
    );
  }
}
