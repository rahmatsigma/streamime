import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/splash_screen.dart'; 

final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash', // Mulai dari splashscreen 

  routes: [

    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [

        GoRoute(
          path: '/', // Path HomeScreen
          builder: (context, state) => const HomeScreen(),
        ),


        GoRoute(
          path: '/favorites', // untuk FavoritesScreen
          builder: (context, state) => const FavoritesScreen(),
        ),
      ],
    ),

    GoRoute(
      path: '/detail/:id', // :id parameter dinamis
      builder: (context, state) {
        final int animeId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        final String animeTitle = state.extra as String? ?? 'Detail';

        return DetailScreen(
          animeId: animeId,
          animeTitle: animeTitle,
        );
      },
    ),
  ],
);