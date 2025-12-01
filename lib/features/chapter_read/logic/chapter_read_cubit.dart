import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';

// STATE SEDERHANA (Langsung disini aja biar cepet)
abstract class ChapterReadState {}

class ChapterReadInitial extends ChapterReadState {}

class ChapterReadLoading extends ChapterReadState {}

class ChapterReadError extends ChapterReadState {
  final String message;
  ChapterReadError(this.message);
}

class ChapterReadLoaded extends ChapterReadState {
  final List<String> images;
  ChapterReadLoaded(this.images);
}

// CUBIT
class ChapterReadCubit extends Cubit<ChapterReadState> {
  final IMangaRepository _repo;

  ChapterReadCubit(this._repo) : super(ChapterReadInitial());

  void getImages(String chapterId) async {
    emit(ChapterReadLoading());
    final result = await _repo.getChapterImages(chapterId: chapterId);

    result.fold(
      (failure) => emit(ChapterReadError(failure.message)),
      (images) => emit(ChapterReadLoaded(images)),
    );
  }
}
