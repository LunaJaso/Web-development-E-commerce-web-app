// imports Flutter design widgets
import 'package:flutter/material.dart';
// import productsPage
import 'productsPage.dart';
// import profilePage
import 'profilePage.dart';
// import cartPage
import 'cartPage.dart';

// Root widget for navigation structure
class MainShell extends StatefulWidget {
  // Constructor and key
  const MainShell({super.key});

  // Sets object to mutable state
  @override
  State<MainShell> createState() => _MainShellState();
}

// State class contains logic that can change while using the applciation
class _MainShellState extends State<MainShell> {
  // Tracks which page is currently open
  int _currentIndex = 0;

  // Pages for each tab
  final pages = [
    const ProductsPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  // Rebuilds the UI every time setState is called
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Shows current page
      body: pages[_currentIndex],

      // bottomNavigationBar for switching between each page
      bottomNavigationBar: BottomNavigationBar(
        // Highlights the currently seleted tab
        currentIndex: _currentIndex,

        // Runs when tapped
        onTap: (index) {
          // Rebuilds UI and updates index number
          setState(() => _currentIndex = index);
        },

        // Each tabs icons and labels
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
