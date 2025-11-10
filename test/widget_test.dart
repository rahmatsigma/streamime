import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/logic/manga_list_cubit.dart';
import 'package:manga_read/main.dart';

class MockMangaRepository implements IMangaRepository {
  @override
  Future<Either<Failure, MangaList>> getPopularManga({required int page}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return const Right([]);
  }

  @override
  Future<Either<Failure, MangaList>> searchManga({required String query}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return const Right([]);
  }
}

void main() {
  testWidgets('App builds and displays home page smoke test', (WidgetTester tester) async {

    final IMangaRepository mockRepository = MockMangaRepository();

    await tester.pumpWidget(
      BlocProvider(
        create: (context) => MangaListCubit(mockRepository),
        child: const MangaReadApp(),
      ),
    );

    await tester.pump();

    await tester.pumpAndSettle();

    expect(find.text('MangaRead - Populer'), findsOneWidget);

    expect(find.byIcon(Icons.search), findsOneWidget);

    expect(find.byIcon(Icons.person), findsOneWidget);

    expect(find.text('Tidak ada manga ditemukan.'), findsOneWidget);
  });
}