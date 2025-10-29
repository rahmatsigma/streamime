// lib/logic/cubit/favorite_state.dart
part of 'favorite_cubit.dart';

// State ini sederhana, cuma bawa daftar anime favorit
class FavoriteState extends Equatable {
  final List<AnimeModel> favorites;

  const FavoriteState({this.favorites = const []});

  @override
  List<Object> get props => [favorites];
}