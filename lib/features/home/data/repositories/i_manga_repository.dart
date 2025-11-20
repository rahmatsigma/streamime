import 'package:dartz/dartz.dart';
import 'package:manga_read/core/api/exceptions.dart';

typedef Failure = ApiException;
typedef MangaList = List<dynamic>;

abstract class IMangaRepository {
  Future<Either<Failure, MangaList>> getPopularManga({required int page});
  Future<Either<Failure, MangaList>> searchManga({required String query});
}