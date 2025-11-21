import 'package:manga_read/models/comic.dart';
import 'package:manga_read/core/image_proxy.dart';

class Manga extends Comic {
  final String readingDirection;
  final String origin;

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
    final id = (json['slug'] ?? json['id'])?.toString() ?? '';
    final title = (json['title']).toString();

    // --- DETEKTIF GAMBAR ---
    var rawData = json['cover_image'] ?? json['image'];
    String finalImageUrl = '';

    // 1. Cek Debug di Console
    if (title.isNotEmpty) {
      print('--- DEBUG MANGA: $title ---');
      print('Tipe Data Gambar: ${rawData.runtimeType}');
      print('Isi Mentah Gambar: $rawData'); // <--- KITA PERLU LIHAT INI
      print('---------------------------');
    }

    // 2. Logika Ekstraksi
    if (rawData != null) {
      if (rawData is String) {
        finalImageUrl = rawData;
      } else if (rawData is Map) {
        // Coba semua kemungkinan key di dalam Map
        finalImageUrl = rawData['url'] ?? 
                        rawData['src'] ?? 
                        rawData['original'] ?? 
                        rawData['image_url'] ?? 
                        rawData['link'] ?? 
                        '';
      } else if (rawData is List && rawData.isNotEmpty) {
        // Siapa tau dia berbentuk List
        final firstItem = rawData.first;
        if (firstItem is String) finalImageUrl = firstItem;
        if (firstItem is Map) finalImageUrl = firstItem['url'] ?? '';
      }
    }

    // 3. GAMBAR CADANGAN (PLACEHOLDER)
    // Jika setelah dicari tetap kosong, pakai gambar abu-abu
    if (finalImageUrl.isEmpty) {
      // Gambar placeholder abu-abu standar
      finalImageUrl = 'https://via.placeholder.com/300x400.png?text=No+Image';
      print('>>> Peringatan: Gambar kosong untuk $title, pakai placeholder.');
    }

    final synopsis = (json['desc'] ?? json['description'] ?? json['synopsis'])?.toString();

    List<String> genres = [];
    final g = json['genres'];
    if (g is List) {
      genres = g.map((e) => e.toString()).toList();
    }

    final author = (json['author'] ?? json['writer'])?.toString();
    final type = normalizeType(json['type'] ?? json['comic_type']);

    return Manga(
      id: id,
      title: title,
      
      // Tetap diproxy agar aman di Web
      imageUrl: ImageProxy.proxy(finalImageUrl),
      
      genres: genres,
      status: json['status']?.toString(),
      chapters: _parseChapterCount(json),
      author: author,
      type: type,
    );
  }

  static int? _parseChapterCount(Map<String, dynamic> json) {
    if (json['chapter_count'] is int) return json['chapter_count'];
    if (json['chapters'] is int) return json['chapters'];
    String? s = json['chapter_count']?.toString() ?? json['chapters']?.toString();
    if (s == null) return null;
    final reg = RegExp(r'(\d+)');
    final match = reg.firstMatch(s);
    if (match != null) return int.tryParse(match.group(0)!);
    return null;
  }
}