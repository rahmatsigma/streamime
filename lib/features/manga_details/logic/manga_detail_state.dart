import 'package:equatable/equatable.dart';
import 'package:manga_read/features/manga_details/data/repositories/i_manga_detail_repository.dart';

abstract class MangaDetailState extends Equatable {
  const MangaDetailState();
  @override
  List<Object?> get props => [];
}

class MangaDetailInitial extends MangaDetailState {}

class MangaDetailLoading extends MangaDetailState {}

class MangaDetailLoaded extends MangaDetailState {
  final MangaDetail manga; // data detail manga
  final ChapterList? chapters; // Daftar chapter (bisa null)
  final bool chaptersLoading; // Status loading chapter
  final String? chapterErrorMessage; // Pesan error jika gagal load chapter

  const MangaDetailLoaded(
    this.manga, {
    this.chapters,
    this.chaptersLoading = false,
    this.chapterErrorMessage,
  });

  @override
  List<Object?> get props => [manga, chapters, chaptersLoading, chapterErrorMessage];

  // copyWith sangat penting untuk update state tanpa mengubah semua data
  MangaDetailLoaded copyWith({
    MangaDetail? manga,
    ChapterList? chapters,
    bool? chaptersLoading,
    String? chapterErrorMessage,
    bool clearChapterError = false, // Helper untuk menghapus error
  }) {
    return MangaDetailLoaded(
      manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      chaptersLoading: chaptersLoading ?? this.chaptersLoading,
      // Jika clearChapterError true, set error ke null
      chapterErrorMessage: clearChapterError 
          ? null 
          : chapterErrorMessage ?? this.chapterErrorMessage,
    );
  }
}

class MangaDetailError extends MangaDetailState {
  final String message;
  const MangaDetailError(this.message);
  @override
  List<Object> get props => [message];
}