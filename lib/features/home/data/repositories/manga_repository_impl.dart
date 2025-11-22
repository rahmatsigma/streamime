import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manga_read/core/api/dio_client.dart';
import 'package:manga_read/core/api/exceptions.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/models/manga.dart'; 

class MangaRepositoryImpl implements IMangaRepository {
  final Dio dio = DioClient().dio;

  @override
  Future<Either<Failure, MangaList>> getPopularManga({required int page}) async {
    try {
      final response = await dio.get(
        '/api/comics', 
        queryParameters: {'page': page}, 
      );

      final List<dynamic> rawData = _extractList(response.data);

      final MangaList mangaList = rawData.map((json) {
        final mangaObj = Manga.fromApi(json);
        return {
          'id': mangaObj.id,
          'title': mangaObj.title,
          'coverUrl': mangaObj.imageUrl,
          'type': mangaObj.type,
          'status': mangaObj.status,
        };
      }).toList();
      
      return Right(mangaList);

    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(NotFoundException('Manga not found'));
      }
      return Left(ServerException(e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(ServerException(e.toString()));
    }
  }

  // ... (Sisanya sama, method searchManga dan _extractList tidak perlu diubah) ...
  @override
  Future<Either<Failure, MangaList>> searchManga({required String query}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await dio.get(
        '/api/search', 
        queryParameters: {'q': encodedQuery}
      );

      final List<dynamic> rawData = _extractList(response.data);
      
      final MangaList mangaList = rawData.map((json) {
        final mangaObj = Manga.fromApi(json);
        return {
          'id': mangaObj.id,
          'title': mangaObj.title,
          'coverUrl': mangaObj.imageUrl, 
        };
      }).toList();
      
      return Right(mangaList);

    } on DioException catch (e) {
       if (e.response?.statusCode == 404) {
        return Left(NotFoundException('Manga not found'));
      }
      return Left(ServerException(e.message ?? 'Unknown error'));
    }
  }

  @override
  Future<Either<Failure, Manga>> getMangaDetail({required String id}) async {
    try {
      // --- LOGIC SEDERHANA: KIRIM ID ANGKA MENTAH-MENTAH ---
      print(">>> REQUEST DETAIL ID (ANGKA): $id");
      print(">>> URL: /api/comics/$id");
      
      final response = await dio.get('/api/comics/$id');

      if (response.statusCode == 200) {
        final dynamic rawData = response.data['data'] ?? response.data;
        final mangaDetail = Manga.fromApi(rawData);
        return Right(mangaDetail);
      } else {
        return Left(ServerException('Gagal: Kode ${response.statusCode}'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(NotFoundException('Manga tidak ditemukan (ID Salah)'));
      }
      // Print error body biar jelas kalau ada apa-apa
      print("ERROR SERVER: ${e.response?.data}");
      return Left(ServerException(e.message ?? 'Koneksi bermasalah'));
    } catch (e) {
      return Left(ServerException('Error parsing: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getChapterImages({required String chapterId}) async {
    try {
      print(">>> REQUEST CHAPTER ID: $chapterId");
      
      // Endpoint kemungkinan besar ini (berdasarkan pola teman abang)
      final response = await dio.get('/api/chapters/$chapterId');

      if (response.statusCode == 200) {
        // Ambil data dari JSON No. 2 yang abang kirim
        // { "data": { "images": [ {"url": "..."} ] } }
        final data = response.data['data'];
        
        List<String> imageUrls = [];

        if (data != null && data['images'] is List) {
          final List images = data['images'];
          
          // Ambil field 'url' dari setiap item
          imageUrls = images.map((img) {
            return (img['url'] ?? '').toString();
          }).where((url) => url.isNotEmpty).toList();
        }
        
        // Debug biar keliatan dapet berapa gambar
        print(">>> DAPAT ${imageUrls.length} GAMBAR");
        
        return Right(imageUrls);
      } else {
        return Left(ServerException('Gagal load chapter: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(NotFoundException('Chapter tidak ditemukan'));
      }
      return Left(ServerException(e.message ?? 'Error Koneksi'));
    } catch (e) {
      return Left(ServerException('Error parsing: $e'));
    }
  }
}

  List _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'];
      if (data['results'] is List) return data['results'];
      if (data['comics'] is List) return data['comics'];
      if (data['items'] is List) return data['items'];
      return [data];
    }
    return [];
  }
