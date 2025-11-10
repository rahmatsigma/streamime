import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/features/manga_details/data/repositories/i_manga_detail_repository.dart';
import 'package:manga_read/features/manga_details/logic/manga_detail_state.dart';

class MangaDetailCubit extends Cubit<MangaDetailState> {
  final IMangaDetailRepository _repository;

  // Terima repository
  MangaDetailCubit(this._repository) : super(MangaDetailInitial());

  // Fungsi untuk memuat data
  void fetchMangaDetails(String mangaId) async {
    emit(MangaDetailLoading());
    final result = await _repository.getMangaDetails(mangaId);

    result.fold(
      (failure) => emit(MangaDetailError(failure.toString())),
      (manga) => emit(MangaDetailLoaded(manga)),
    );
  }

  void fetchMangaChapters(String mangaId) async {
  // Hanya berjalan jika state saat ini adalah MangaDetailLoaded
  final currentState = state;
  if (currentState is! MangaDetailLoaded) return;

  // 1. Emit state loading chapter
  emit(currentState.copyWith(
    chaptersLoading: true,
    clearChapterError: true, // Hapus error lama jika ada
  ));

  // 2. Panggil repository
  final result = await _repository.getMangaChapters(mangaId);

  // 3. Emit state baru berdasarkan hasil
  result.fold(
    (failure) {
      emit(currentState.copyWith(
        chaptersLoading: false,
        chapterErrorMessage: failure.toString(),
      ));
    },
    (chapters) {
      emit(currentState.copyWith(
        chaptersLoading: false,
        chapters: chapters,
      ));
    },
  );
}
}