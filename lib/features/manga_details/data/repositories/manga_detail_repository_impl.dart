import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manga_read/core/api/dio_client.dart';
import 'package:manga_read/core/api/exceptions.dart';
import 'package:manga_read/features/manga_details/data/repositories/i_manga_detail_repository.dart';

class MangaDetailRepositoryImpl implements IMangaDetailRepository {
  final Dio dio = DioClient().dio;

  @override
  Future<Either<Failure, MangaDetail>> getMangaDetails(String mangaId) async {
    try {
      final response = await dio.get('/manga/$mangaId');

      if (response.statusCode == 200) {
        final mangaData = response.data['data'];
        final MangaDetail mangaDetail = {
          'id': mangaData['mal_id'].toString(),
          'title': mangaData['title'],
          'description': mangaData['synopsis'] ?? 'No description available.',
          'coverUrl': mangaData['images']['jpg']['image_url'],
          'genres': (mangaData['genres'] as List<dynamic>)
              .map((genre) => genre['name'] as String)
              .toList(),
        };
        return Right(mangaDetail);
      } else {
        return Left(ServerException('Failed to load manga details'));
      }
    } on DioException catch (e) {
      return Left(ServerException(e.message ?? 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, ChapterList>> getMangaChapters(String mangaId) async {
    // TODO: Implement chapter fetching from Jikan API
    // Jikan API does not have a direct endpoint for chapters.
    // This will require more research.
    return Right([]);
  }
}