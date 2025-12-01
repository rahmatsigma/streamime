import 'package:dio/dio.dart';
import 'package:manga_read/core/constants.dart';

class DioClient {
  // Buat instance Dio singleton
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 120000),
        receiveTimeout: const Duration(milliseconds: 120000),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Tambahkan token otentikasi ke setiap permintaan
          // Ini adalah contoh Enkapsulasi (Menyembunyikan logika auth)
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Anda bisa menangani error secara global di sini
          // Misalnya: jika token expired, refresh token
          return handler.next(e);
        },
      ),
    );
  }
}
