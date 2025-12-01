import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/logic/manga_list_cubit.dart';
import 'package:manga_read/features/theme/logic/theme_cubit.dart';
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/auth/logic/auth_state.dart';
import 'package:manga_read/main.dart';
import 'package:manga_read/core/api/exceptions.dart';
import 'package:manga_read/models/manga.dart';

// --- 1. MOCK REPOSITORY ---
class MockMangaRepository implements IMangaRepository {
  @override
  Future<Either<Failure, MangaList>> getPopularManga({required int page}) async {
    await Future.delayed(const Duration(milliseconds: 10)); 
    return const Right([]);
  }

  @override
  Future<Either<Failure, MangaList>> searchManga({required String query}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Manga>> getMangaDetail({required String id}) async {
    return Right(Manga(id: '1', title: 'Test', imageUrl: '', genres: []));
  }

  @override
  Future<Either<Failure, List<String>>> getChapterImages({required String chapterId}) async {
    return const Right([]);
  }
  
  @override
  Stream<List<Manga>> getFavoritesStream(String uid) {
    return Stream.value([]);
  }

  @override
  Stream<List<Map<String, dynamic>>> getHistoryStream(String uid) {
    return Stream.value([]);
  }
  
  @override
  Future<void> addToHistory(String uid, Manga manga, String chapterTitle, String chapterId) async {}
  
  @override
  Future<bool> isMangaFavorite(String uid, String mangaId) async => false;
  
  @override
  Future<void> toggleFavorite(String uid, Manga manga, bool isCurrentlyFavorite) async {}
}

// --- 2. MOCK AUTH CUBIT ---
class MockAuthCubit extends Cubit<AuthState> implements AuthCubit {
  MockAuthCubit() : super(const AuthState(status: AuthStatus.unauthenticated, user: null));

  @override
  Future<void> checkAuthStatus() async {}
  
  @override
  Future<void> signOut() async {}
  
  @override
  void init() {} 

  @override
  Stream<User?> get userStream => Stream.value(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App splash screen to home navigation test', (WidgetTester tester) async {
    // A. Set Ukuran Layar 
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;

    // B. Mock Setup
    SharedPreferences.setMockInitialValues({}); 
    final IMangaRepository mockRepository = MockMangaRepository();
    final AuthCubit mockAuthCubit = MockAuthCubit();

    // C. Pump Widget
    await tester.pumpWidget(
      RepositoryProvider<IMangaRepository>.value(
        value: mockRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => MangaListCubit(mockRepository)),
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          ],
          child: const MangaReadApp(),
        ),
      ),
    );

    // D. FASE 1: SPLASH SCREEN
    await tester.pump(); 
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle(); 

    // F. FASE 3: HOME PAGE
    expect(find.text('MangaRead - Populer'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    
    // Bersihkan settingan layar setelah tes
    addTearDown(tester.view.resetPhysicalSize);
  });
}