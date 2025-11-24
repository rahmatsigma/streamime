import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/chapter_read/logic/chapter_read_cubit.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/core/image_proxy.dart';

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
      create: (context) => ChapterReadCubit(
        context.read<IMangaRepository>(),
      )..getImages(chapterId),
      child: Scaffold(
        backgroundColor: Colors.black,
        // AppBar bisa disembunyikan/dimunculkan, tapi kita biarkan sederhana dulu
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.9),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Reader", style: TextStyle(color: Colors.white)),
          actions: [
            // Tombol info chapter saat ini
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  _getCurrentChapterTitle(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            )
          ],
        ),
        body: BlocBuilder<ChapterReadCubit, ChapterReadState>(
          builder: (context, state) {
            if (state is ChapterReadLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChapterReadError) {
              return Center(
                  child: Text("Error: ${state.message}",
                      style: const TextStyle(color: Colors.white)));
            }
            if (state is ChapterReadLoaded) {
              if (state.images.isEmpty) {
                return const Center(
                    child: Text("Tidak ada gambar.",
                        style: TextStyle(color: Colors.white)));
              }

              // Kita tambah 1 item di bawah untuk tombol Navigasi
              return ListView.builder(
                itemCount: state.images.length + 1, 
                cacheExtent: 3000,
                itemBuilder: (context, index) {
                  // Jika index terakhir, tampilkan Tombol Navigasi
                  if (index == state.images.length) {
                    return _buildNavigationButtons(context);
                  }

                  // Tampilkan Gambar
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
                          child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Helper untuk mendapatkan judul chapter saat ini
  String _getCurrentChapterTitle() {
    final current = chapters.firstWhere(
      (c) => c['id'] == chapterId, 
      orElse: () => {'title': 'Chapter'}
    );
    return current['title'];
  }

  // Logic Tombol Next/Prev
  Widget _buildNavigationButtons(BuildContext context) {
    // 1. Cari index chapter saat ini
    final currentIndex = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (currentIndex == -1) return const SizedBox.shrink();

    // LOGIKA URUTAN:
    // Biasanya list chapter dari API urutannya DESCENDING (Paling baru di atas).
    // Contoh: [Ch 100, Ch 99, Ch 98, ... Ch 1]
    // Jadi:
    // NEXT Chapter (Ch 100) adalah index - 1
    // PREV Chapter (Ch 98) adalah index + 1
    
    Map<String, dynamic>? nextChapter;
    Map<String, dynamic>? prevChapter;

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // TOMBOL PREV (Mundur)
          if (prevChapter != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                // Gunakan pushReplacement agar tidak menumpuk halaman di stack
                context.pushReplacement('/read/${prevChapter!['id']}', extra: chapters);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Prev"),
            )
          else
            const SizedBox(width: 80), // Spacer biar layout seimbang

          // TOMBOL NEXT (Maju)
          if (nextChapter != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                context.pushReplacement('/read/${nextChapter!['id']}', extra: chapters);
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Next"), // Icon di kiri, teks di kanan
            )
          else
             // Kalau sudah chapter paling baru
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text("Selesai"),
            ),
        ],
      ),
    );
  }
}