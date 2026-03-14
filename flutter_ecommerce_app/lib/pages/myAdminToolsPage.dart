import 'package:flutter/material.dart';

class MyAdminToolsPage extends StatelessWidget {
  const MyAdminToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Tools')),
      body: const Center(child: Text('Admin panel here')),
    );
  }
}