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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),

      // Detail Manga
      GoRoute(
        path: '/manga-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MangaDetailPage(mangaId: id);
        },
      ),

      // Reader (Baca Komik)
      GoRoute(
        path: '/read/:chapterId',
        builder: (context, state) {
          final chapterId = state.pathParameters['chapterId']!;
          return ChapterReadPage(chapterId: chapterId);
        },
      ),

      // Login Page
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Favorite Page (SUDAH DIBERSIHKAN)
      GoRoute(
        path: '/favorites',
        builder: (context, state) {
          // Tidak perlu kirim parameter isLoggedIn / list lagi
          return const FavoritePage(); 
        },
      ),

      // History Page (SUDAH DIBERSIHKAN)
      GoRoute(
        path: '/history',
        builder: (context, state) {
          // Tidak perlu kirim parameter lagi
          return const ReadingHistoryPage();
        },
      ),

      // Settings Page
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}