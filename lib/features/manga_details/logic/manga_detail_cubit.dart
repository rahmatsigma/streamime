import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/core/api/exceptions.dart';
// PENTING: Import Model Manga yang baru
import 'package:manga_read/models/manga.dart'; 
// PENTING: Gunakan Repository Utama (karena kita mindahin fungsi detail ke sana)
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart'; 
import 'manga_detail_state.dart';

class MangaDetailCubit extends Cubit<MangaDetailState> {
  // Gunakan IMangaRepository (bukan DetailRepository lagi)
  final IMangaRepository _repository; 

  MangaDetailCubit(this._repository) : super(MangaDetailInitial());

  Future<void> getMangaDetail(String id) async {
    emit(MangaDetailLoading());

    // Panggil fungsi getMangaDetail yang ada di repository utama
    final result = await _repository.getMangaDetail(id: id);

    result.fold(
      (failure) => emit(MangaDetailError(failure.message)),
      (manga) => emit(MangaDetailLoaded(manga)), // manga ini tipe-nya class Manga
    );
  }
}