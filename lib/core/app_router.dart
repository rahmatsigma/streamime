import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/home/presentation/pages/home_page.dart';
import 'package:manga_read/features/manga_details/presentation/pages/manga_detail_page.dart';
import 'package:manga_read/features/manga_reader/presentation/pages/reader_page.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/manga-detail/:mangaId', // ':mangaId' adalah parameter
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
    ],
    // Optional: error builder
    errorBuilder: (context, state) => const Scaffold(
  body: Center(
        child: Text('Halaman tidak ditemukan'),
      ),
    ),
  );
}   