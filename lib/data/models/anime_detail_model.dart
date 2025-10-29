// data/models/anime_detail_model.dart
import 'package:equatable/equatable.dart';

class AnimeDetailModel extends Equatable {
  final int id;
  final String title;
  final String imageUrl;
  final String synopsis;
  final double score;
  final int? episodes;
  final String status;

  const AnimeDetailModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.synopsis,
    required this.score,
    this.episodes,
    required this.status,
  });

  factory AnimeDetailModel.fromJson(Map<String, dynamic> json) {
    return AnimeDetailModel(
      id: json['mal_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      imageUrl: json['images']?['jpg']?['large_image_url'] ?? // Ambil gambar yg lebih besar
          json['images']?['jpg']?['image_url'] ?? '',
      synopsis: json['synopsis'] ?? 'No synopsis available.',
      score: (json['score'] ?? 0.0).toDouble(),
      episodes: json['episodes'], // Bisa jadi null (misal: "ongoing")
      status: json['status'] ?? 'Unknown',
    );
  }

  @override
  List<Object?> get props => [id, title, imageUrl, synopsis, score, episodes, status];
}