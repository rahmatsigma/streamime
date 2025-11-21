// File: lib/models/comic.dart

// Helper untuk normalisasi tipe data
String? normalizeType(dynamic t) {
  if (t == null) return null;
  if (t is String) return t;
  if (t is Map) return (t['name'] ?? t['type'] ?? t['nama'])?.toString();
  if (t is List && t.isNotEmpty) return normalizeType(t.first);
  return t.toString();
}

class Comic {
  final String id;
  final String title;
  final String? titleEnglish;
  final String? synopsis;
  final String imageUrl;
  final List<String> genres;
  final String? status;
  final int? chapters;
  final String? author;
  final String? type;

  Comic({
    required this.id,
    required this.title,
    this.titleEnglish,
    this.synopsis,
    required this.imageUrl,
    required this.genres,
    this.status,
    this.chapters,
    this.author,
    this.type,
  });

  Map<String, dynamic> getAdditionalInfo() {
    return {
      if (status != null) 'Status': status,
      if (type != null) 'Type': type,
    };
  }
}