import 'package:equatable/equatable.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';

abstract class MangaListState extends Equatable {
  const MangaListState();
  @override
  List<Object?> get props => [];
}

class MangaListInitial extends MangaListState {}

class MangaListLoading extends MangaListState {}

// 'Loaded' state sekarang jauh lebih canggih
class MangaListLoaded extends MangaListState {
  final MangaList mangaList; // Daftar manga yang sudah digabung
  final bool hasReachedMax; // Tanda jika sudah tidak ada data lagi
  final bool isLoadingMore; // Tanda sedang loading lebih banyak data

  const MangaListLoaded({
    required this.mangaList,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  // copyWith sangat penting untuk update state
  MangaListLoaded copyWith({
    MangaList? mangaList,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return MangaListLoaded(
      mangaList: mangaList ?? this.mangaList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [mangaList, hasReachedMax, isLoadingMore];
}

class MangaListError extends MangaListState {
  final String message;
  const MangaListError(this.message);
  @override
  List<Object> get props => [message];
}
