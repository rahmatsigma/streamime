import 'package:dartz/dartz.dart';
import 'package:manga_read/core/api/exceptions.dart'; // Ambil Failure dari sini
import 'package:manga_read/models/manga.dart';


typedef MangaList = List<Map<String, dynamic>>;
abstract class IMangaRepository {
  Future<Either<Failure, MangaList>> getPopularManga({required int page});  
  Future<Either<Failure, MangaList>> searchManga({required String query});
  Future<Either<Failure, Manga>> getMangaDetail({required String id});
  Future<Either<Failure, List<String>>> getChapterImages({required String chapterId});
}