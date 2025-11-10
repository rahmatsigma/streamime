import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manga_read/core/api/dio_client.dart';
import 'package:manga_read/features/manga_details/data/repositories/i_manga_detail_repository.dart';

class MangaDetailRepositoryImpl implements IMangaDetailRepository {
  final Dio dio = DioClient().dio;

  @override
  Future<Either<Failure, MangaDetail>> getMangaDetails(String mangaId) async {
    try {
      // Endpoint MangaDex untuk detail manga berdasarkan ID
      final response = await dio.get(
        '/manga/$mangaId',
        queryParameters: {
          'includes[]': 'cover_art' // Minta data cover art
        },
      );

      if (response.statusCode == 200) {
        // Data detail ada di response.data['data']
        return Right(response.data['data']);
      } else {
        return Left(Exception('Gagal memuat detail manga'));
      }
    } on DioException catch (e) {
      return Left(Exception(e.message));
    }
  }

  @override
  Future<Either<Failure, ChapterList>> getMangaChapters(String mangaId) async {
    try {
      // Endpoint MangaDex untuk daftar chapter (feed)
      final response = await dio.get(
        '/manga/$mangaId/feed',
        queryParameters: {
          'order[chapter]': 'desc',      // Urutkan dari chapter terbaru (descending)
          'limit': 500,                  // Ambil maks 500 chapter
        },
      );

      if (response.statusCode == 200) {
        // Data chapter ada di response.data['data']
        return Right(response.data['data'] as List<dynamic>);
      } else {
        return Left(Exception('Gagal memuat chapter'));
      }
    } on DioException catch (e) {
      return Left(Exception(e.message));
    }
  }
}