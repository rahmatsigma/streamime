import 'package:manga_read/models/comic.dart';
import 'package:manga_read/core/image_proxy.dart';

class Manga extends Comic {
  final String readingDirection;
  final String origin;
  // Wadah baru untuk menyimpan daftar chapter
  final List<Map<String, dynamic>> chapterList; 

  Manga({
    required super.id,
    required super.title,
    super.titleEnglish,
    super.synopsis,
    required super.imageUrl,
    required super.genres,
    super.status,
    super.chapters,
    super.author,
    super.type,
    this.readingDirection = 'Right to Left',
    this.origin = 'Japan 🇯🇵',
    this.chapterList = const [], // Default kosong
  });

  @override
  Map<String, dynamic> getAdditionalInfo() {
    return {
      ...super.getAdditionalInfo(),
      'Origin': origin,
      'Reading Direction': readingDirection,
    };
  }

  factory Manga.fromApi(Map<String, dynamic> json) {
    // 1. ID
    final id = json['id']?.toString() ?? json['slug']?.toString() ?? '';
    final title = (json['title']).toString();

    // 2. GAMBAR
    var rawData = json['cover_image'] ?? json['image'];
    String finalImageUrl = '';
    if (rawData != null) {
      if (rawData is String) {
        finalImageUrl = rawData;
      } else if (rawData is Map) {
        finalImageUrl = rawData['url'] ?? rawData['src'] ?? '';
      }
    }
    if (finalImageUrl.isEmpty) {
        finalImageUrl = 'https://via.placeholder.com/300x400.png?text=No+Image';
    }

    // 3. LOGIC LAINNYA
    final synopsis = (json['desc'] ?? json['description'] ?? json['synopsis'])?.toString();
    
    List<String> genres = [];
    final g = json['genres'];
    if (g is List) {
      genres = g.map((e) => e.toString()).toList();
    }

    final author = (json['author'] ?? json['writer'])?.toString();
    final type = normalizeType(json['type'] ?? json['comic_type']);

    // --- 4. LOGIC CHAPTER (BARU) ---
    // Kita ambil array 'chapters' dari JSON dan masukkan ke list
    List<Map<String, dynamic>> parsedChapters = [];
    if (json['chapters'] is List) {
      parsedChapters = (json['chapters'] as List).map((ch) {
        return {
          // Ambil ID Chapter (penting buat diklik nanti)
          'id': ch['id']?.toString() ?? '', 
          // Nama Chapter (misal: "Chapter 1")
          'title': ch['name'] ?? ch['title'] ?? ch['chapter_number'] ?? 'Chapter ?',
          // Tanggal rilis (opsional)
          'date': ch['created_at'] ?? '',
        };
      }).toList();
    }
    // -------------------------------

    return Manga(
      id: id,
      title: title,
      imageUrl: ImageProxy.proxy(finalImageUrl),
      genres: genres,
      status: json['status']?.toString(),
      chapters: _parseChapterCount(json),
      author: author,
      type: type,
      chapterList: parsedChapters, // Masukkan data chapter ke sini
    );
  }

  static int? _parseChapterCount(Map<String, dynamic> json) {
    if (json['chapter_count'] is int) return json['chapter_count'];
    if (json['chapters'] is int) return json['chapters']; // Kalau formatnya int
    if (json['chapters'] is List) return (json['chapters'] as List).length; // Kalau formatnya list
    return null;
  }
}