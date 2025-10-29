// lib/presentation/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart'; // Wadah BottomNavBar

// Key unik untuk ShellRoute (BottomNavBar)
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: '/', // Mulai dari path '/' (HomeScreen)

  routes: [
    // --- SHELL ROUTE (Untuk Halaman dengan BottomNavBar) ---
    // Ini adalah rute "wadah" yang akan selalu menampilkan MainScreen (BottomNavBar)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        // MainScreen akan jadi "bingkai" dan 'child' adalah halaman 
        // yang aktif (HomeScreen atau FavoritesScreen)
        return MainScreen(child: child);
      },
      routes: [
        // Sub-rute untuk tab 1 (Home)
        GoRoute(
          path: '/', // Path untuk HomeScreen
          builder: (context, state) => const HomeScreen(),
        ),
        // Sub-rute untuk tab 2 (Favorites)
        GoRoute(
          path: '/favorites', // Path untuk FavoritesScreen
          builder: (context, state) => const FavoritesScreen(),
        ),
      ],
    ),

    // --- ROUTE BIASA (Untuk Halaman Tanpa BottomNavBar) ---
    // Rute ini akan tampil menutupi seluruh layar (termasuk BottomNavBar)
    GoRoute(
      path: '/detail/:id', // :id adalah parameter dinamis
      builder: (context, state) {
        // 1. Ambil 'id' dari path
        // Kita parse ke int, jika gagal (null) kita beri default 0
        final int animeId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;

        // 2. Ambil 'title' dari parameter 'extra'
        // 'extra' adalah cara GoRouter mengirim objek kompleks
        final String animeTitle = state.extra as String? ?? 'Detail';

        return DetailScreen(
          animeId: animeId,
          animeTitle: animeTitle,
        );
      },
    ),
  ],
);