import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/anime_detail_model.dart'; // Import model detail
import '../../data/repositories/anime_repository.dart';

part 'anime_detail_state.dart';

class AnimeDetailCubit extends Cubit<AnimeDetailState> {
  final AnimeRepository _repository;

  AnimeDetailCubit(this._repository) : super(AnimeDetailInitial());

  // Fungsi untuk mengambil data detail berdasarkan ID
  void fetchAnimeDetail(int animeId) async {
    try {
      emit(AnimeDetailLoading());
      final anime = await _repository.getAnimeDetail(animeId);
      emit(AnimeDetailSuccess(anime));
    } catch (e) {
      emit(AnimeDetailError(e.toString()));
    }
  }
}