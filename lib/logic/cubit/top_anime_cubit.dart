// lib/logic/cubit/top_anime_cubit.dart
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/anime_model.dart';
import '../../data/repositories/anime_repository.dart';

part 'top_anime_state.dart';

class TopAnimeCubit extends Cubit<TopAnimeState> {
  final AnimeRepository _repository;

  TopAnimeCubit(this._repository) : super(TopAnimeInitial());

  // Fungsi fetchTopAnime (sedikit berubah)
  void fetchTopAnime() async {
    try {
      emit(TopAnimeLoading());
      // Selalu mulai dari halaman 1
      final animeList = await _repository.getTopAnime(page: 1);
      
      emit(TopAnimeSuccess(
        animeList: animeList,
        currentPage: 1,
        hasReachedMax: animeList.isEmpty,
        currentQuery: '', // Set query kosong (mode Top Anime)
      ));
    } catch (e) {
      emit(TopAnimeError(e.toString()));
    }
  }
  
  // Fungsi searchAnime (sedikit berubah)
  void searchAnime(String query) async {
    // Jika query kosong, kembalikan ke daftar top anime
    if (query.isEmpty) {
      fetchTopAnime();
      return;
    }

    try {
      emit(TopAnimeLoading());
      // Selalu mulai dari halaman 1
      final animeList = await _repository.searchAnime(query, page: 1);
      
      emit(TopAnimeSuccess(
        animeList: animeList,
        currentPage: 1,
        hasReachedMax: animeList.isEmpty,
        currentQuery: query, // Simpan query yg sedang dicari
      ));
    } catch (e) {
      emit(TopAnimeError(e.toString()));
    }
  }

  // --- FUNGSI BARU: loadMore ---
  void loadMore() async {
    // 1. Cek state saat ini. Hanya TopAnimeSuccess yg bisa load more
    if (state is! TopAnimeSuccess) return;

    final currentState = state as TopAnimeSuccess;

    // 2. Jika sudah mentok, jangan panggil API lagi
    if (currentState.hasReachedMax) return;

    try {
      // 3. Tentukan apakah kita load more untuk Top Anime atau Search
      List<AnimeModel> newAnimeList;
      final nextPage = currentState.currentPage + 1;

      if (currentState.currentQuery.isEmpty) {
        // Mode Top Anime
        newAnimeList = await _repository.getTopAnime(page: nextPage);
      } else {
        // Mode Search
        newAnimeList = await _repository.searchAnime(currentState.currentQuery, page: nextPage);
      }

      // 4. Emit state baru dengan data gabungan
      if (newAnimeList.isEmpty) {
        // Data baru kosong, berarti sudah mentok
        emit(currentState.copyWith(hasReachedMax: true));
      } else {
        // Gabungkan list lama + list baru
        emit(currentState.copyWith(
          animeList: currentState.animeList..addAll(newAnimeList),
          currentPage: nextPage,
          hasReachedMax: false,
        ));
      }
    } catch (e) {
      // Jika load more gagal, kita bisa diam saja atau emit error
      // Di sini kita biarkan, agar user bisa coba scroll lagi
      developer.log(
        'Error loading more anime',
        error: e,
        name: 'TopAnimeCubit',
      );
    }
  }
}
