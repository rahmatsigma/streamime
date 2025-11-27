import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/data/repositories/manga_repository_impl.dart'; 
import 'manga_detail_state.dart';

class MangaDetailCubit extends Cubit<MangaDetailState> {
  final IMangaRepository _repository;

  MangaDetailCubit(this._repository) : super(MangaDetailInitial());

  // 1. Load Detail (Update dikit buat cek status awal favorite)
  Future<void> getMangaDetail(String id, {String? userId}) async {
    emit(MangaDetailLoading());

    final result = await _repository.getMangaDetail(id: id);

    result.fold(
      (failure) => emit(MangaDetailError(failure.message)),
      (manga) async {
        bool isFav = false;
        
        // Cek ke Firestore kalau user login
        if (userId != null && _repository is MangaRepositoryImpl) {
           isFav = await (_repository as MangaRepositoryImpl).isMangaFavorite(userId, id);
        }
        
        // Emit Loaded dengan status favorite
        emit(MangaDetailLoaded(manga, isFavorite: isFav));
      },
    );
  }

  // 2. Simpan History (Fitur yang tadi kita bahas)
  Future<void> saveHistoryIfLoggedIn(String? userId, String chapterTitle, String chapterId) async {
    if (state is MangaDetailLoaded && userId != null) {
      final currentManga = (state as MangaDetailLoaded).manga;
      
      if (_repository is MangaRepositoryImpl) {
        // Kirim chapterId ke repository
        await (_repository as MangaRepositoryImpl).addToHistory(userId, currentManga, chapterTitle, chapterId);
      }
    }
  }

  // 3. Toggle Favorite (INI YANG ERROR TADI KARENA HILANG)
  Future<void> toggleFavorite(String userId) async {
    if (state is MangaDetailLoaded) {
      final currentState = state as MangaDetailLoaded;
      final currentManga = currentState.manga;
      final currentStatus = currentState.isFavorite;

      // Optimistic Update: Ubah warna hati duluan biar UI terasa cepat
      emit(currentState.copyWith(isFavorite: !currentStatus));

      // Kirim ke Backend
      if (_repository is MangaRepositoryImpl) {
        try {
          await (_repository as MangaRepositoryImpl).toggleFavorite(userId, currentManga, currentStatus);
        } catch (e) {
          // Kalau gagal simpan, balikin warna hatinya
          emit(currentState.copyWith(isFavorite: currentStatus));
        }
      }
    }
  }
}