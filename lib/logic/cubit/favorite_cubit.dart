// lib/logic/cubit/favorite_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart'; // <-- IMPORT HIVE
import '../../data/models/anime_model.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {

  // Ambil box 'favorites' yang sudah kita buka di main.dart
  final Box<AnimeModel> _favoriteBox = Hive.box<AnimeModel>('favorites');

  FavoriteCubit() : super(const FavoriteState());

  // Fungsi untuk memuat data dari Hive saat app start
  void loadFavorites() {
    // .values mengembalikan semua item di box
    final favorites = _favoriteBox.values.toList();
    emit(FavoriteState(favorites: favorites));
  }

  // Fungsi untuk menambah/menghapus favorit
  void toggleFavorite(AnimeModel anime) {
    final currentFavorites = List<AnimeModel>.from(state.favorites);

    // Cek apakah anime sudah ada di favorit
    if (isFavorite(anime.id)) {
      // HAPUS DARI FAVORIT
      // Di Hive, kita hapus pakai 'key'. Kita set 'key' = 'id'
      _favoriteBox.delete(anime.id);
      currentFavorites.removeWhere((item) => item.id == anime.id);
    } else {
      // TAMBAH KE FAVORIT
      // Kita pakai 'id' sebagai 'key' unik
      _favoriteBox.put(anime.id, anime);
      currentFavorites.add(anime);
    }

    // Emit state baru
    emit(FavoriteState(favorites: currentFavorites));
  }

  // Fungsi helper untuk cek status
  bool isFavorite(int animeId) {
    return _favoriteBox.containsKey(animeId);
  }
}