import 'package:dartz/dartz.dart';

// Kita pakai 'dynamic' lagi untuk 'Failure' dan 'MangaDetail'
typedef Failure = dynamic;
typedef MangaDetail = dynamic;
typedef ChapterList = dynamic;

abstract class IMangaDetailRepository {
  Future<Either<Failure, MangaDetail>> getMangaDetails(String mangaId);
  Future<Either<Failure, ChapterList>> getMangaChapters(String mangaId);
}