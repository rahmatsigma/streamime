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

  // Fungsi Pencarian 
  Future<void> searchManga(String query, {String? filterType, String? filterStatus}) async {
    if (query.isEmpty) {
      await fetchPopularManga();
      return;
    }

    emit(MangaListLoading());
    _isFetching = true;

    final result = await _repository.searchManga(query: query);

    result.fold(
      (failure) => emit(MangaListError(failure.message)),
      (mangaList) {
        var filteredList = mangaList;

        if (filterType != null && filterType != 'All') {
          filteredList = filteredList.where((manga) {
            final type = manga['type']?.toString().toLowerCase() ?? '';
            return type == filterType.toLowerCase();
          }).toList();
        }

        if (filterStatus != null && filterStatus != 'All') {
          filteredList = filteredList.where((manga) {
            final status = manga['status']?.toString().toLowerCase() ?? '';
            return status.contains(filterStatus.toLowerCase());
          }).toList();
        }

        emit(MangaListLoaded(
          mangaList: filteredList,
          hasReachedMax: true,
          isLoadingMore: false,
        ));
      },
    );
    _isFetching = false;
  }
}