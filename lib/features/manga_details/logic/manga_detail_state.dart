import 'package:equatable/equatable.dart';
import 'package:manga_read/models/manga.dart'; // Import Manga

abstract class MangaDetailState extends Equatable {
  const MangaDetailState();

  @override
  List<Object> get props => [];
}

class MangaDetailInitial extends MangaDetailState {}

class MangaDetailLoading extends MangaDetailState {}

class MangaDetailLoaded extends MangaDetailState {
  final Manga manga; // GANTI 'MangaDetail' JADI 'Manga'

  const MangaDetailLoaded(this.manga);

  @override
  List<Object> get props => [manga];
}

class MangaDetailError extends MangaDetailState {
  final String message;

  const MangaDetailError(this.message);

  @override
  List<Object> get props => [message];
}