// lib/presentation/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- IMPORT GO_ROUTER

class MainScreen extends StatelessWidget {
  // Terima 'child' (halaman aktif) dari ShellRoute
  final Widget child;
  
  const MainScreen({super.key, required this.child});

  // Fungsi untuk mengecek index aktif berdasarkan route
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == '/favorites') {
      return 1;
    }
    return 0; // Defaultnya adalah '/' (Home)
  }

  // Fungsi untuk pindah tab
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/'); // Pindah ke path '/'
        break;
      case 1:
        context.go('/favorites'); // Pindah ke path '/favorites'
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body-nya sekarang adalah 'child' yang diberikan GoRouter
      body: child, 

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        // Tentukan index aktif berdasarkan path URL
        currentIndex: _calculateSelectedIndex(context),
        selectedItemColor: Colors.cyan,
        onTap: (index) => _onItemTapped(index, context), // Panggil fungsi pindah
      ),
    );
  }
}