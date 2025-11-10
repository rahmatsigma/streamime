import 'package:dartz/dartz.dart';

typedef Failure = dynamic;
typedef PageUrlList = List<String>; // Kita hanya butuh daftar URL gambar

abstract class IReaderRepository {
  // Fungsi ini akan mengembalikan daftar URL gambar yang sudah jadi
  Future<Either<Failure, PageUrlList>> getChapterPages(String chapterId);
}