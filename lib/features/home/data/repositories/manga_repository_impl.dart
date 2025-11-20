import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manga_read/core/api/dio_client.dart';
import 'package:manga_read/core/api/exceptions.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';

class MangaRepositoryImpl implements IMangaRepository {
  final Dio dio = DioClient().dio;

  @override
  Future<Either<Failure, MangaList>> getPopularManga(
      {required int page}) async {
    try {
      final response = await dio.get('/top/manga', queryParameters: {'page': page});

      if (response.statusCode == 200) {
        final List<dynamic> mangaData = response.data['data'];
        final MangaList mangaList = mangaData.map((manga) {
          return {
            'id': manga['mal_id'].toString(),
            'title': manga['title'],
            'coverUrl': manga['images']['jpg']['image_url'],
          };
        }).toList();
        return Right(mangaList);
      } else {
        return Left(ServerException('Failed to load manga'));
      }
    }
    on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(NotFoundException('Manga not found'));
      }
      return Left(ServerException(e.message ?? 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, MangaList>> searchManga(
      {required String query}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await dio.get('/manga', queryParameters: {'q': encodedQuery});

      if (response.statusCode == 200) {
        final List<dynamic> mangaData = response.data['data'];
        final MangaList mangaList = mangaData.map((manga) {
          return {
            'id': manga['mal_id'].toString(),
            'title': manga['title'],
            'coverUrl': manga['images']['jpg']['image_url'],
          };
        }).toList();
        return Right(mangaList);
      } else {
        return Left(ServerException('Failed to search manga'));
      }
    }
    on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(NotFoundException('Manga not found'));
      }
      return Left(ServerException(e.message ?? 'Unknown error'));
    }
  }
}

