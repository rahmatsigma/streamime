// lib/logic/cubit/top_anime_state.dart
part of 'top_anime_cubit.dart';

abstract class TopAnimeState extends Equatable {
  const TopAnimeState();
  @override
  List<Object?> get props => [];
}

class TopAnimeInitial extends TopAnimeState {}

class TopAnimeLoading extends TopAnimeState {}

// --- MODIFIKASI TopAnimeSuccess ---
// Kita akan buat state ini lebih canggih
class TopAnimeSuccess extends TopAnimeState {
  final List<AnimeModel> animeList;
  final bool hasReachedMax;
  final int currentPage;
  final String currentQuery; // Menyimpan query pencarian terakhir

  const TopAnimeSuccess({
    this.animeList = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.currentQuery = '', // Defaultnya kosong (mode Top Anime)
  });

  // Fungsi copyWith sangat penting untuk update state
  TopAnimeSuccess copyWith({
    List<AnimeModel>? animeList,
    bool? hasReachedMax,
    int? currentPage,
    String? currentQuery,
  }) {
    return TopAnimeSuccess(
      animeList: animeList ?? this.animeList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }

  @override
  List<Object?> get props => [animeList, hasReachedMax, currentPage, currentQuery];
}

class TopAnimeError extends TopAnimeState {
  final String message;

  const TopAnimeError(this.message);

  @override
  List<Object> get props => [message];
}