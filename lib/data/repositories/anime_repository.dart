// lib/data/repositories/anime_repository.dart
import 'package:dio/dio.dart';
import '../models/anime_model.dart';
import '../models/anime_detail_model.dart';

class AnimeRepository {
  final Dio _dio;
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  AnimeRepository({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  // --- MODIFIKASI getTopAnime ---
  Future<List<AnimeModel>> getTopAnime({int page = 1}) async { // Tambah parameter page
    try {
      final response = await _dio.get(
        '/top/anime',
        queryParameters: {'page': page}, // Kirim parameter page ke API
      );
      
      final List rawData = response.data['data'];
      final List<AnimeModel> animeList =
          rawData.map((json) => AnimeModel.fromJson(json)).toList();
      return animeList;

    } on DioException catch (e) {
      print('Dio error: $e');
      throw Exception('Failed to load top anime: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Fungsi getAnimeDetail (Tidak berubah)
  Future<AnimeDetailModel> getAnimeDetail(int animeId) async {
    // ... (kode ini tidak perlu diubah)
    try {
      final response = await _dio.get('/anime/$animeId');
      final AnimeDetailModel detail = AnimeDetailModel.fromJson(response.data['data']);
      return detail;
    } on DioException catch (e) {
      print('Dio error: $e');
      throw Exception('Failed to load anime detail: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- MODIFIKASI searchAnime ---
  Future<List<AnimeModel>> searchAnime(String query, {int page = 1}) async { // Tambah parameter page
    try {
      final response = await _dio.get(
        '/anime',
        queryParameters: {
          'q': query,
          'limit': 20, 
          'page': page, // Kirim parameter page ke API
        },
      );
      
      final List rawData = response.data['data'];
      final List<AnimeModel> animeList = rawData
          .map((json) => AnimeModel.fromJson(json))
          .toList();
      return animeList;

    } on DioException catch (e) {
      print('Dio error: $e');
      throw Exception('Failed to load search results: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}