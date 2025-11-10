import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/features/manga_reader/data/repositories/i_reader_repository.dart';
import 'package:manga_read/features/manga_reader/logic/reader_state.dart';

class ReaderCubit extends Cubit<ReaderState> {
  final IReaderRepository _repository;

  ReaderCubit(this._repository) : super(ReaderInitial());

  void fetchChapterPages(String chapterId) async {
    emit(ReaderLoading());
    final result = await _repository.getChapterPages(chapterId);

    result.fold(
      (failure) => emit(ReaderError(failure.toString())),
      (pageUrls) => emit(ReaderLoaded(pageUrls)),
    );
  }
}