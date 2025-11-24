import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/logic/manga_list_state.dart';

class MangaListCubit extends Cubit<MangaListState> {
  final IMangaRepository _repository;
  int _currentPage = 1;
  bool _isFetching = false;

  MangaListCubit(this._repository) : super(MangaListInitial()) {
    fetchPopularManga(); 
  }

  Future<void> getPopularManga({required int page}) async {
    if (page == 1) {
      await fetchPopularManga();
    }
  }

  // --- 2. FETCH DATA (Diubah jadi Future) ---
  Future<void> fetchPopularManga() async {
    emit(MangaListLoading());
    _currentPage = 1;
    _isFetching = true;

    final result = await _repository.getPopularManga(page: _currentPage);

    result.fold(
      (failure) => emit(MangaListError(failure.message)),
      (mangaList) => emit(MangaListLoaded(
        mangaList: mangaList,
        hasReachedMax: mangaList.isEmpty,
      )),
    );
    _isFetching = false;
  }

  // Fungsi untuk mengambil data selanjutnya (Infinite Scroll)
  Future<void> loadMoreManga() async {
    // Jangan lakukan apapun jika sedang fetching atau data sudah habis
    if (_isFetching || (state is MangaListLoaded && (state as MangaListLoaded).hasReachedMax)) {
      return;
    }

    // Pastikan state saat ini adalah Loaded
    if (state is MangaListLoaded) {
      final currentState = state as MangaListLoaded;
      _isFetching = true;
      emit(currentState.copyWith(isLoadingMore: true));

      _currentPage++; 
      final result = await _repository.getPopularManga(page: _currentPage);

      result.fold(
        (failure) {
          emit(currentState.copyWith(
            isLoadingMore: false,
          ));
        },
        (newMangaList) {
          emit(currentState.copyWith(
            mangaList: currentState.mangaList + newMangaList,
            hasReachedMax: newMangaList.isEmpty, 
            isLoadingMore: false,
          ));
        },
      );
      _isFetching = false;
    }
  }

  // Fungsi Pencarian (Diubah jadi Future)
  Future<void> searchManga(String query) async {
    // Jika query kosong, panggil ulang daftar 'populer'
    if (query.isEmpty) {
      await fetchPopularManga();
      return;
    }

    // Tampilkan loading screen penuh
    emit(MangaListLoading());
    _isFetching = true; // Mencegah infinite scroll saat mode cari

    final result = await _repository.searchManga(query: query);

    result.fold(
      (failure) => emit(MangaListError(failure.message)),
      (mangaList) {
        // Tampilkan hasil search
        emit(MangaListLoaded(
          mangaList: mangaList,
          hasReachedMax: true, // Matikan infinite scroll untuk hasil search
          isLoadingMore: false,
        ));
      },
    );
    _isFetching = false;
  }
}