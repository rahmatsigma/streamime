part of 'anime_detail_cubit.dart';

abstract class AnimeDetailState extends Equatable {
  const AnimeDetailState();
  @override
  List<Object> get props => [];
}

class AnimeDetailInitial extends AnimeDetailState {}

class AnimeDetailLoading extends AnimeDetailState {}

class AnimeDetailSuccess extends AnimeDetailState {
  final AnimeDetailModel anime;

  const AnimeDetailSuccess(this.anime);

  @override
  List<Object> get props => [anime];
}

class AnimeDetailError extends AnimeDetailState {
  final String message;

  const AnimeDetailError(this.message);

  @override
  List<Object> get props => [message];
}