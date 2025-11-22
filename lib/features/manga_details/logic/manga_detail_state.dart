import 'package:equatable/equatable.dart';
import 'package:manga_read/models/manga.dart';

abstract class MangaDetailState extends Equatable {
  const MangaDetailState();

  @override
  List<Object> get props => [];
}

class MangaDetailInitial extends MangaDetailState {}

class MangaDetailLoading extends MangaDetailState {}

class MangaDetailLoaded extends MangaDetailState {
  final Manga manga;
  final bool isFavorite; // <--- TAMBAHAN PENTING

  // Default isFavorite false kalau tidak diisi
  const MangaDetailLoaded(this.manga, {this.isFavorite = false});

  @override
  List<Object> get props => [manga, isFavorite];

  // Fungsi CopyWith (Wajib ada buat update UI tanpa reload ulang API)
  MangaDetailLoaded copyWith({Manga? manga, bool? isFavorite}) {
    return MangaDetailLoaded(
      manga ?? this.manga,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class MangaDetailError extends MangaDetailState {
  final String message;

  const MangaDetailError(this.message);

  @override
  List<Object> get props => [message];
}