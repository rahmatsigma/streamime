import 'package:manga_read/models/comic.dart';
import 'package:manga_read/core/image_proxy.dart';

class Manga extends Comic {
  String _readingDirection;
  String _origin;
  List<Map<String, dynamic>> _chapterList;

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
    String readingDirection = 'Right to Left',
    String origin = 'Japan',
    List<Map<String, dynamic>> chapterList = const [],
  }) : _readingDirection = readingDirection,
       _origin = origin,
       _chapterList = List<Map<String, dynamic>>.from(chapterList);

  String get readingDirection => _readingDirection;
  set readingDirection(String value) {
    if (value.isNotEmpty) _readingDirection = value;
  }

  String get origin => _origin;
  set origin(String value) {
    if (value.isNotEmpty) _origin = value;
  }

  List<Map<String, dynamic>> get chapterList => List.unmodifiable(_chapterList);
  set chapterList(List<Map<String, dynamic>> value) {
    _chapterList = List<Map<String, dynamic>>.from(value);
  }

  @override
  Map<String, dynamic> getAdditionalInfo() {
    return {
      ...super.getAdditionalInfo(),
      'Origin': _origin,
      'Reading Direction': _readingDirection,
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

    // 3. SINOPSIS
    String? rawDesc = (json['desc'] ?? json['description'] ?? json['synopsis'])
        ?.toString();
    if (rawDesc != null && (rawDesc.trim().isEmpty || rawDesc == 'null')) {
      rawDesc = null;
    }
    final synopsis = rawDesc;

    // --- 4. GENRES (LOGIC PINTAR) ---
    List<String> genres = [];
    // Cek berbagai kemungkinan nama key
    final rawGenres = json['genres'] ?? json['genre'] ?? json['genres_list'];

    if (rawGenres != null) {
      if (rawGenres is List) {
        // Jika formatnya List: ["Action", "Magic"] atau [{"name": "Action"}]
        genres = rawGenres
            .map((g) {
              if (g is Map) {
                // Ambil nama dari dalam object
                return (g['name'] ?? g['title'] ?? g['genre'] ?? '').toString();
              }
              return g.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList(); // Hapus yang kosong
      } else if (rawGenres is String) {
        // Jika formatnya String panjang: "Action, Magic, Fantasy"
        genres = rawGenres
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    // -------------------------------

    final author = (json['author'] ?? json['writer'])?.toString();
    final type = normalizeType(json['type'] ?? json['comic_type']);

    // 5. CHAPTERS
    List<Map<String, dynamic>> parsedChapters = [];
    if (json['chapters'] is List) {
      parsedChapters = (json['chapters'] as List).map((ch) {
        return {
          'id': ch['id']?.toString() ?? '',
          'title':
              ch['name'] ?? ch['title'] ?? ch['chapter_number'] ?? 'Chapter ?',
          'date': ch['created_at'] ?? '',
          'mangaId': id,
        };
      }).toList();
    }

    return Manga(
      id: id,
      title: title,
      imageUrl: ImageProxy.proxy(finalImageUrl),
      genres: genres,
      status: json['status']?.toString(),
      chapters: _parseChapterCount(json),
      author: author,
      type: type,
      chapterList: parsedChapters,
      synopsis: synopsis,
    );
  }

  static int? _parseChapterCount(Map<String, dynamic> json) {
    if (json['chapter_count'] is int) return json['chapter_count'];
    if (json['chapters'] is int) return json['chapters'];
    if (json['chapters'] is List) return (json['chapters'] as List).length;
    return null;
  }
}
