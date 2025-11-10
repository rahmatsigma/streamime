import 'package:dartz/dartz.dart';

typedef Failure = dynamic;
typedef MangaList = List<dynamic>;

abstract class IMangaRepository {
  Future<Either<Failure, MangaList>> getPopularManga({required int page});
  Future<Either<Failure, MangaList>> searchManga({required String query});
}