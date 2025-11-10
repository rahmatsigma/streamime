import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/auth/presentation/pages/login_page.dart';
import 'package:manga_read/features/auth/presentation/pages/register_page.dart';
import 'package:manga_read/features/favorites/presentation/pages/favorite_page.dart';
import 'package:manga_read/features/history/presentation/pages/reading_history_page.dart';
import 'package:manga_read/features/home/presentation/pages/home_page.dart';
import 'package:manga_read/features/manga_details/presentation/pages/manga_detail_page.dart';
import 'package:manga_read/features/manga_reader/presentation/pages/reader_page.dart';
import 'package:manga_read/features/settings/presentation/pages/settings_page.dart';
// --- IMPORT BARU ---
import 'package:manga_read/features/splash/presentation/pages/splash_screen.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    // --- AKHIR PERUBAHAN ---
    routes: [
      // --- ROUTE BARU ---
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // --- AKHIR ROUTE BARU ---
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/manga-detail/:mangaId',
        builder: (context, state) {
          final String mangaId = state.pathParameters['mangaId']!;
          return MangaDetailPage(mangaId: mangaId);
        },
      ),
      GoRoute(
        path: '/reader/:chapterId',
        builder: (context, state) {
          final String chapterId = state.pathParameters['chapterId']!;
          return ReaderPage(chapterId: chapterId);
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) {
          bool isLoggedIn = false;
          List<String> favorites = const <String>[];

          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            final favs = extra['favorites'];
            final loggedIn = extra['isLoggedIn'];
            if (favs is List<String>) {
              favorites = List<String>.from(favs);
            }
            if (loggedIn is bool) {
              isLoggedIn = loggedIn;
            }
          }

          return FavoritePage(
            isLoggedIn: isLoggedIn,
            favoriteManga: favorites,
          );
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) {
          bool isLoggedIn = false;
          List<String> historyItems = const <String>[];

          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            final history = extra['history'];
            final loggedIn = extra['isLoggedIn'];
            if (history is List<String>) {
              historyItems = List<String>.from(history);
            }
            if (loggedIn is bool) {
              isLoggedIn = loggedIn;
            }
          }

          return ReadingHistoryPage(
            isLoggedIn: isLoggedIn,
            historyItems: historyItems,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan'),
      ),
    ),
  );
}