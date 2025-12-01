import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/auth/logic/auth_state.dart';
import 'package:manga_read/features/chapter_read/logic/chapter_read_cubit.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/data/repositories/manga_repository_impl.dart'; // Import Impl buat akses history
import 'package:manga_read/core/image_proxy.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class ChapterReadPage extends StatelessWidget {
  final String chapterId;
  final List<Map<String, dynamic>> chapters; // Terima daftar chapter

  const ChapterReadPage({
    super.key,
    required this.chapterId,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChapterReadCubit(context.read<IMangaRepository>())
            ..getImages(chapterId),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.9),
          iconTheme: const IconThemeData(color: Colors.white),
          // Tampilkan Judul Chapter
          title: Text(
            _getCurrentChapterTitle(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // Info Posisi (Contoh: 5 / 20)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  "${_getCurrentIndex() + 1} / ${chapters.length}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<ChapterReadCubit, ChapterReadState>(
          builder: (context, state) {
            if (state is ChapterReadLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChapterReadError) {
              return Center(
                child: Text(
                  "Error: ${state.message}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            if (state is ChapterReadLoaded) {
              if (state.images.isEmpty) {
                return const Center(
                  child: Text(
                    "Tidak ada gambar.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // --- FITUR ZOOM: InteractiveViewer ---
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0, // Bisa zoom sampai 4x lipat
                child: ListView.builder(
                  // Tambah 1 item di bawah untuk tombol navigasi
                  itemCount: state.images.length + 1,
                  cacheExtent: 3000,
                  itemBuilder: (context, index) {
                    // Jika index terakhir, tampilkan Tombol Navigasi
                    if (index == state.images.length) {
                      return _buildNavigationButtons(context);
                    }

                    // Tampilkan Gambar Komik
                    final url = state.images[index];
                    return Image.network(
                      ImageProxy.proxy(url),
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 200,
                        child: Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Helper: Cari Index yang Aman (String vs Int)
  int _getCurrentIndex() {
    if (chapters.isEmpty) return -1;
    return chapters.indexWhere(
      (c) => c['id'].toString() == chapterId.toString(),
    );
  }

  String _getCurrentChapterTitle() {
    int index = _getCurrentIndex();
    if (index != -1) {
      return chapters[index]['title'] ?? 'Chapter Reader';
    }
    return 'Chapter Reader';
  }

  // Helper: Update History saat klik Next/Prev
  Future<void> _updateHistory(
    BuildContext context,
    String targetChapterId,
    String targetChapterTitle,
  ) async {
    final authState = context.read<AuthCubit>().state;
    final repo = context.read<IMangaRepository>();

    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      final userId = authState.user!.uid;

      // Cari data chapter target untuk ambil mangaId-nya
      final targetChapter = chapters.firstWhere(
        (c) => c['id'].toString() == targetChapterId.toString(),
        orElse: () => {},
      );

      final String mangaId = targetChapter['mangaId'] ?? '';

      if (mangaId.isNotEmpty && repo is MangaRepositoryImpl) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('history')
              .doc(mangaId)
              .update({
                'lastChapter': targetChapterTitle,
                'chapterId': targetChapterId,
                'lastReadAt': FieldValue.serverTimestamp(),
              });
          print("History updated: $targetChapterTitle");
        } catch (e) {
          print("Gagal update history next: $e");
        }
      }
    }
  }

  // Widget: Tombol Next/Prev
  Widget _buildNavigationButtons(BuildContext context) {
    final currentIndex = _getCurrentIndex();

    // Kalau list kosong atau ID gak ketemu, sembunyikan tombol
    if (chapters.isEmpty || currentIndex == -1) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            "Navigasi tidak tersedia",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    Map<String, dynamic>? nextChapter;
    Map<String, dynamic>? prevChapter;

    // Logika API
    if (currentIndex > 0) {
      nextChapter = chapters[currentIndex - 1]; // Maju ke chapter lebih baru
    }

    if (currentIndex < chapters.length - 1) {
      prevChapter = chapters[currentIndex + 1]; // Mundur ke chapter lama
    }

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (prevChapter != null)
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  _updateHistory(
                    context,
                    prevChapter!['id'],
                    prevChapter!['title'],
                  );
                  context.pushReplacement(
                    '/read/${prevChapter!['id']}',
                    extra: chapters,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Prev"),
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 16),

          if (nextChapter != null)
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  _updateHistory(
                    context,
                    nextChapter!['id'],
                    nextChapter!['title'],
                  );
                  context.pushReplacement(
                    '/read/${nextChapter!['id']}',
                    extra: chapters,
                  );
                },
                label: const Text("Next"),
                icon: const Icon(Icons.arrow_forward),
              ),
            )
          else
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                child: const Text("Selesai"),
              ),
            ),
        ],
      ),
    );
  }
}
