import 'package:dartz/dartz.dart';
import 'package:manga_read/core/api/exceptions.dart'; // Ambil Failure dari sini
import 'package:manga_read/models/manga.dart';

// Definisi tipe data list
typedef MangaList = List<Map<String, dynamic>>;

abstract class IMangaRepository {
  // Gunakan 'Failure', bukan 'ApiException'
  Future<Either<Failure, MangaList>> getPopularManga({required int page});
  
  Future<Either<Failure, MangaList>> searchManga({required String query});

  Future<Either<Failure, Manga>> getMangaDetail({required String id});
}