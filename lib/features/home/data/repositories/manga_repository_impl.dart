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
      // --- 1. BERSIHKAN ID (SOLUSI ERROR 400) ---
      // ID dari API Popular biasanya formatnya: "manga/judul-komik"
      // Kita harus membuang bagian "manga/" agar tersisa "judul-komik" saja.
      
      String cleanId = id;
      if (cleanId.startsWith('manga/')) {
        cleanId = cleanId.replaceFirst('manga/', '');
      } else if (cleanId.startsWith('manhwa/')) {
        cleanId = cleanId.replaceFirst('manhwa/', '');
      } else if (cleanId.startsWith('manhua/')) {
        cleanId = cleanId.replaceFirst('manhua/', '');
      }

      // Jika ada garis miring di akhir, hapus juga
      if (cleanId.endsWith('/')) {
        cleanId = cleanId.substring(0, cleanId.length - 1);
      }

      print(">>> ID ASLI: $id");
      print(">>> ID BERSIH: $cleanId"); // <-- Harusnya sisa 'zui-qiang-shen-wang'
      
      // --- 2. REQUEST KE ENDPOINT BERSIH ---
      final response = await dio.get('/api/comics/$cleanId');

      if (response.statusCode == 200) {
        final dynamic rawData = response.data['data'] ?? response.data;
        
        // Masukkan ke Model Manga
        final mangaDetail = Manga.fromApi(rawData);
        
        return Right(mangaDetail);
      } else {
        return Left(ServerException('Gagal: Kode ${response.statusCode}'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(NotFoundException('Manga tidak ditemukan (404)'));
      }
      return Left(ServerException(e.message ?? 'Koneksi bermasalah'));
    } catch (e) {
      return Left(ServerException('Error parsing: $e'));
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
}