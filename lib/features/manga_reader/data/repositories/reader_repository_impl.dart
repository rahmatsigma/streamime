import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manga_read/core/api/dio_client.dart';
import 'package:manga_read/features/manga_reader/data/repositories/i_reader_repository.dart';

class ReaderRepositoryImpl implements IReaderRepository {
  final Dio dio = DioClient().dio;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getChapterPages(
      String chapterId) async {
    try {
      // 1. Panggil endpoint /at-home/server/{id}
      final response = await dio.get('/at-home/server/$chapterId');

      if (response.statusCode == 200) {
        // 2. Ekstrak data yang diperlukan dari respons
        final String baseUrl = response.data['baseUrl'];
        final String hash = response.data['chapter']['hash'];
        final List<dynamic> pageFilenames = response.data['chapter']['data'];
        final String title = response.data['chapter']['title'] ?? 'No Title';

        // 3. Bangun (construct) daftar URL gambar
        final PageUrlList pageUrls = [];
        for (final filename in pageFilenames) {
          // Format URL: {baseUrl}/data/{hash}/{filename}
          final String url = '$baseUrl/data/$hash/$filename';
          pageUrls.add(url);
        }

        // 4. Kembalikan daftar URL yang sudah lengkap
        return Right({
          'title': title,
          'pages': pageUrls,
        });
      } else {
        return Left(Exception('Gagal memuat data server chapter'));
      }
    } on DioException catch (e) {
      return Left(Exception(e.message));
    }
  }
}