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
  String _id;
  String _title;
  String? _titleEnglish;
  String? _synopsis;
  String _imageUrl;
  List<String> _genres;
  String? _status;
  int? _chapters;
  String? _author;
  String? _type;

  Comic({
    required String id,
    required String title,
    String? titleEnglish,
    String? synopsis,
    required String imageUrl,
    required List<String> genres,
    String? status,
    int? chapters,
    String? author,
    String? type,
  }) : _id = id,
       _title = title,
       _titleEnglish = titleEnglish,
       _synopsis = synopsis,
       _imageUrl = imageUrl,
       _genres = List<String>.from(genres),
       _status = status,
       _chapters = chapters,
       _author = author,
       _type = type;

  String get id => _id;
  set id(String value) {
    if (value.isNotEmpty) _id = value;
  }

  String get title => _title;
  set title(String value) {
    if (value.isNotEmpty) _title = value;
  }

  String? get titleEnglish => _titleEnglish;
  set titleEnglish(String? value) => _titleEnglish = value;

  String? get synopsis => _synopsis;
  set synopsis(String? value) => _synopsis = value;

  String get imageUrl => _imageUrl;
  set imageUrl(String value) {
    if (value.isNotEmpty) _imageUrl = value;
  }

  List<String> get genres => List.unmodifiable(_genres);
  set genres(List<String> values) {
    _genres = List<String>.from(values);
  }

  String? get status => _status;
  set status(String? value) => _status = value;

  int? get chapters => _chapters;
  set chapters(int? value) => _chapters = value;

  String? get author => _author;
  set author(String? value) => _author = value;

  String? get type => _type;
  set type(String? value) => _type = value;

  Map<String, dynamic> getAdditionalInfo() {
    return {
      if (_status != null) 'Status': _status,
      if (_type != null) 'Type': _type,
    };
  }
}
