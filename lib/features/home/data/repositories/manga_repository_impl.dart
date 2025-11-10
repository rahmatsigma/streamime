import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manga_read/core/api/dio_client.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';

class MangaRepositoryImpl implements IMangaRepository {
  final Dio dio = DioClient().dio;

  // Kita tentukan batasnya di sini
  static const int _mangaLimit = 20;

  @override
  Future<Either<Failure, MangaList>> getPopularManga(
      {required int page}) async {
    try {
      // Hitung offset berdasarkan halaman
      // Halaman 1 -> offset 0
      // Halaman 2 -> offset 20
      final int offset = (page - 1) * _mangaLimit;

      final response = await dio.get('/manga', queryParameters: {
        'order[followedCount]': 'desc',
        'limit': _mangaLimit, // Ambil 20 per halaman
        'offset': offset, // Mulai dari offset
        'includes[]': 'cover_art'
      });

      if (response.statusCode == 200) {
        final List<dynamic> mangaList = response.data['data'];
        return Right(mangaList);
      } else {
        return Left(Exception('Failed to load manga'));
      }
    } on DioException catch (e) {
      return Left(Exception(e.message));
    }
  }

  @override
  Future<Either<Failure, MangaList>> searchManga(
      {required String query}) async {
    try {
      final response = await dio.get('/manga', queryParameters: {
        'title': query, // Parameter untuk search berdasarkan judul
        'limit': 20, // Batasi 20 hasil teratas
        'order[relevance]': 'desc', // Urutkan berdasarkan relevansi
        'includes[]': 'cover_art'
      });

      if (response.statusCode == 200) {
        final List<dynamic> mangaList = response.data['data'];
        return Right(mangaList);
      } else {
        return Left(Exception('Failed to search manga'));
      }
    } on DioException catch (e) {
      return Left(Exception(e.message));
    }
  }
}