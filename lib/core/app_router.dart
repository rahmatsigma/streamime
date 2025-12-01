import 'package:go_router/go_router.dart';
import 'package:manga_read/features/auth/presentation/pages/login_page.dart';
import 'package:manga_read/features/auth/presentation/pages/register_page.dart';
import 'package:manga_read/features/chapter_read/presentation/pages/chapter_read_page.dart';
import 'package:manga_read/features/favorites/presentation/pages/favorite_page.dart';
import 'package:manga_read/features/home/presentation/pages/home_page.dart';
import 'package:manga_read/features/history/presentation/pages/reading_history_page.dart';
import 'package:manga_read/features/manga_details/presentation/pages/manga_detail_page.dart';
import 'package:manga_read/features/settings/presentation/pages/settings_page.dart';
import 'package:manga_read/features/splash/presentation/pages/splash_screen.dart';
import 'package:manga_read/features/settings/presentation/pages/about_us_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),

      // Detail Manga
      GoRoute(
        path: '/manga-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MangaDetailPage(mangaId: id);
        },
      ),

      // Reader
      GoRoute(
        path: '/read/:chapterId',
        builder: (context, state) {
          final chapterId = state.pathParameters['chapterId']!;
          List<Map<String, dynamic>> chapterList = [];
          if (state.extra != null && state.extra is List) {
            chapterList = (state.extra as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }

          return ChapterReadPage(chapterId: chapterId, chapters: chapterList);
        },
      ),

      // Login Page
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Favorite Page
      GoRoute(
        path: '/favorites',
        builder: (context, state) {
          return const FavoritePage();
        },
      ),

      // History Page
      GoRoute(
        path: '/history',
        builder: (context, state) {
          return const ReadingHistoryPage();
        },
      ),

      // Settings Page
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),

      GoRoute(path: '/about', builder: (context, state) => const AboutUsPage()),
    ],
  );
}
