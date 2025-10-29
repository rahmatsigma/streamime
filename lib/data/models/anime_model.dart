// lib/data/models/anime_model.dart
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart'; // <-- IMPORT HIVE

part 'anime_model.g.dart'; // <-- TAMBAHKAN PART FILE (akan error dulu, wajar)

@HiveType(typeId: 0) // <-- ANOTASI HIVE (typeId harus unik per model)
class AnimeModel extends Equatable {
  
  @HiveField(0) // <-- ANOTASI FIELD
  final int id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String imageUrl;
  
  @HiveField(3)
  final double score;

  const AnimeModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.score,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      id: json['mal_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      imageUrl: json['images']?['jpg']?['image_url'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
    );
  }

  // Kita override props agar Equatable tetap jalan
  @override
  List<Object?> get props => [id, title, imageUrl, score];

  // Kita override stringify agar Equatable tetap jalan
  @override
  bool? get stringify => true;
}