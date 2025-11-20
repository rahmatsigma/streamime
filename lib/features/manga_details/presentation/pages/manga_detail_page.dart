import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter untuk tombol back
import 'package:manga_read/features/manga_details/data/repositories/manga_detail_repository_impl.dart';
import 'package:manga_read/features/manga_details/logic/manga_detail_cubit.dart';
import 'package:manga_read/features/manga_details/logic/manga_detail_state.dart';
import 'package:manga_read/core/image_proxy.dart';

// Helper extension untuk membuat huruf pertama kapital (cth: 'safe' -> 'Safe')
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return "";
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class MangaDetailPage extends StatelessWidget {
  final String mangaId;
  const MangaDetailPage({Key? key, required this.mangaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MangaDetailCubit(MangaDetailRepositoryImpl())
        ..fetchMangaDetails(mangaId), // Langsung panggil fetch detail
      child: Scaffold(
        // AppBar baru dengan tombol back
        appBar: AppBar(
          title: const Text('Detail Manga'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(), // Fungsi GoRouter untuk kembali
          ),
        ),
        body: BlocBuilder<MangaDetailCubit, MangaDetailState>(
          builder: (context, state) {
            if (state is MangaDetailLoading || state is MangaDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MangaDetailError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is MangaDetailLoaded) {
              final manga = state.manga;

              // --- PERUBAHAN ---
              // Trigger pengambilan chapter jika datanya belum ada
              if (state.chapters == null &&
                  !state.chaptersLoading &&
                  state.chapterErrorMessage == null) {
                context.read<MangaDetailCubit>().fetchMangaChapters(mangaId);
              }
              // --- AKHIR PERUBAHAN ---

              // Ekstrak semua data yang kita butuhkan
              final String title = manga['title'];
              final String description = manga['description'];
              final String coverUrl = manga['coverUrl'];
              final List<String> genres = manga['genres'];

              // Gunakan LayoutBuilder untuk UI Responsif
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Jika layar lebar (web/desktop), tampilkan 2 kolom
                  bool isDesktop = constraints.maxWidth > 700;

                  if (isDesktop) {
                    return _buildDesktopLayout(context, title, description,
                        coverUrl, genres, state); // <-- Pass 'state'
                  } else {
                    // Jika layar sempit (HP), tampilkan 1 kolom
                    return _buildMobileLayout(context, title, description,
                        coverUrl, genres, state); // <-- Pass 'state'
                  }
                },
              );
            }

            return const Center(child: Text('State tidak dikenal'));
          },
        ),
      ),
    );
  }

  // --- WIDGET LAYOUT BARU: Mobile (1 kolom) ---
  Widget _buildMobileLayout(
      BuildContext context,
      String title,
      String description,
      String coverUrl,
      List<String> genres,
      MangaDetailLoaded state) { // <-- Terima 'state'
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Center(child: _buildCoverImage(coverUrl)),
            const SizedBox(height: 24),
            // Info Section
            _buildInfoSection(context, title, description,
                genres, state), // <-- Pass 'state'
          ],
        ),
      ),
    );
  }

  // --- WIDGET LAYOUT BARU: Desktop (2 kolom) ---
  Widget _buildDesktopLayout(
      BuildContext context,
      String title,
      String description,
      String coverUrl,
      List<String> genres,
      MangaDetailLoaded state) { // <-- Terima 'state'
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom Kiri: Cover Image
            _buildCoverImage(coverUrl),
            const SizedBox(width: 32),
            // Kolom Kanan: Info (Expanded agar mengisi sisa ruang)
            Expanded(
              child: _buildInfoSection(context, title, description, genres,
                  state), // <-- Pass 'state'
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET REUSABLE: Cover Image ---
  Widget _buildCoverImage(String coverUrl) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 250, // Lebar tetap
        height: 250 * 1.4, // Rasio aspek gambar
        child: Image.network(
          ImageProxy.proxy(coverUrl),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            return progress == null
                ? child
                : const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stack) {
            // Tampilkan icon jika gambar gagal dimuat
            return const Center(child: Icon(Icons.broken_image, size: 50));
          },
        ),
      ),
    );
  }

  // --- WIDGET REUSABLE: Info Section (Title, Genres, Desc, Chapters) ---
  Widget _buildInfoSection(
      BuildContext context,
      String title,
      String description,
      List<String> genres,
      MangaDetailLoaded state) { // <-- Terima 'state'
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Genres (Tags)
        Text('Genres & Tags', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: genres
              .map((genre) => Chip(
                    label: Text(genre),
                    backgroundColor:
                        Theme.of(context).chipTheme.secondarySelectedColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),

        // Deskripsi
        Text('Deskripsi', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(
          description,
          style: textTheme.bodyLarge,
        ),

        // --- KODE BARU UNTUK CHAPTER ---
        const SizedBox(height: 24),
        const Divider(), // Pemisah
        const SizedBox(height: 16),

        // Judul bagian Chapter
        Text('Chapters', style: textTheme.titleLarge),
        const SizedBox(height: 12),

        // Widget baru untuk menampilkan daftar chapter
        _buildChapterList(context, state),
        // --- AKHIR KODE BARU ---

        const SizedBox(height: 24), // Spasi di bawah
      ],
    );
  }

  // --- WIDGET HELPER BARU: Daftar Chapter ---
  /// Widget helper untuk membangun daftar chapter
  Widget _buildChapterList(BuildContext context, MangaDetailLoaded state) {
    // 1. Tampilkan loading
    if (state.chaptersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Tampilkan error
    if (state.chapterErrorMessage != null) {
      return Center(
        child: Text(
          'Gagal memuat chapter: ${state.chapterErrorMessage}',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    // 3. Jika data belum ada (tapi tidak loading/error), jangan tampilkan apa-apa
    if (state.chapters == null) {
      return const SizedBox.shrink();
    }

    // 4. Jika daftar chapter kosong
    if (state.chapters!.isEmpty) {
      return const Center(child: Text('Tidak ada chapter (B. Inggris) ditemukan.'));
    }

    final chapterList = state.chapters!;

    // 5. Tampilkan ListView!
    // Kita batasi tingginya agar tidak mengacaukan layout SingleChildScrollView
    return Container(
      height: 400, // Beri tinggi maksimal untuk daftar chapter
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true, // Penting di dalam Column/SingleChildScrollView
        itemCount: chapterList.length,
        itemBuilder: (context, index) {
          final chapter = chapterList[index];
          final String chapterId = chapter['id'];
          final String chapterTitle = chapter['title'];
          final String chapterNumber = chapter['chapter'];

          return ListTile(
            title: Text('Chapter $chapterNumber: $chapterTitle'),
            leading: const Icon(Icons.book_outlined),
            onTap: () {
              context.push('/reader/$chapterId');
            },
          );
        },
      ),
    );
  }
}