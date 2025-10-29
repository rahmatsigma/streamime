// lib/presentation/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'favorites_screen.dart'; // <-- Halaman baru kita
import 'home_screen.dart';      // <-- Halaman lama kita

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index untuk melacak tab mana yang aktif
  int _selectedIndex = 0;

  // Daftar halaman/screen yang akan ditampilkan
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),      // Tab 0
    FavoritesScreen(), // Tab 1
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body-nya adalah halaman yang kita pilih
      // Kita pakai IndexedStack agar state halaman (posisi scroll)
      // tidak ter-reset saat ganti tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Bottom Navigation Bar
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan, // Warna item aktif
        onTap: _onItemTapped,
      ),
    );
  }
}