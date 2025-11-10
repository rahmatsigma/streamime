import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/logic/manga_list_state.dart';

class MangaListCubit extends Cubit<MangaListState> {
  final IMangaRepository _repository;

  // Variabel internal untuk melacak state pagination
  int _currentPage = 1;
  bool _isFetching = false; // Mencegah panggilan ganda

  MangaListCubit(this._repository) : super(MangaListInitial()) {
    fetchPopularManga(); // Panggil data halaman pertama
  }

  // Fungsi ini untuk panggil Halaman 1 (Fresh Load)
  void fetchPopularManga() async {
    emit(MangaListLoading());
    _currentPage = 1;
    _isFetching = true;

    final result = await _repository.getPopularManga(page: _currentPage);

    result.fold(
      (failure) => emit(MangaListError(failure.toString())),
      (mangaList) => emit(MangaListLoaded(
        mangaList: mangaList,
        hasReachedMax: mangaList.isEmpty,
      )),
    );
    _isFetching = false;
  }

  // Fungsi BARU untuk mengambil data selanjutnya
  void loadMoreManga() async {
    // Jangan lakukan apapun jika sedang fetching atau data sudah habis
    if (_isFetching || (state is MangaListLoaded && (state as MangaListLoaded).hasReachedMax)) {
      return;
    }

    // Pastikan state saat ini adalah Loaded
    if (state is MangaListLoaded) {
      final currentState = state as MangaListLoaded;
      _isFetching = true;

      // 1. Tampilkan loading spinner di bawah list
      emit(currentState.copyWith(isLoadingMore: true));

      _currentPage++; // Naikkan nomor halaman
      final result = await _repository.getPopularManga(page: _currentPage);

      result.fold(
        (failure) {
          // Jika gagal, kembali ke state sebelumnya
          emit(currentState.copyWith(
            isLoadingMore: false,
            // (Opsional) bisa tambahkan pesan error
          ));
        },
        (newMangaList) {
          // 2. Gabungkan list lama + list baru
          emit(currentState.copyWith(
            mangaList: currentState.mangaList + newMangaList,
            hasReachedMax: newMangaList.isEmpty, // Jika data baru kosong = habis
            isLoadingMore: false,
          ));
        },
      );
      _isFetching = false;
    }
  }

  void searchManga(String query) async {
    // Jika query kosong, panggil ulang daftar 'populer'
    if (query.isEmpty) {
      fetchPopularManga();
      return;
    }

    // Tampilkan loading screen penuh
    emit(MangaListLoading());
    _isFetching = true; // Mencegah infinite scroll

    final result = await _repository.searchManga(query: query);

    result.fold(
      (failure) => emit(MangaListError(failure.toString())),
      (mangaList) {
        // Tampilkan hasil search
        emit(MangaListLoaded(
          mangaList: mangaList,
          hasReachedMax: true, // PENTING: Matikan infinite scroll untuk hasil search
          isLoadingMore: false,
        ));
      },
    );
    _isFetching = false;
  }
}