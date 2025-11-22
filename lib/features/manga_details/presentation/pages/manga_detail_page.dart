import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart'; // Gunakan Repo Utama
import 'package:manga_read/features/manga_details/logic/manga_detail_cubit.dart';
import 'package:manga_read/features/manga_details/logic/manga_detail_state.dart';
import 'package:manga_read/models/manga.dart'; // Gunakan Model Manga Baru

class MangaDetailPage extends StatelessWidget {
  final String mangaId;
  const MangaDetailPage({super.key, required this.mangaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MangaDetailCubit(
        // Inject Repository Utama yang sudah ada di main.dart
        context.read<IMangaRepository>(),
      )..getMangaDetail(mangaId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Manga'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<MangaDetailCubit, MangaDetailState>(
          builder: (context, state) {
            if (state is MangaDetailLoading || state is MangaDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MangaDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<MangaDetailCubit>().getMangaDetail(mangaId),
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              );
            }

            if (state is MangaDetailLoaded) {
              final Manga manga = state.manga;

              // Gunakan LayoutBuilder untuk UI Responsif
              return LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 700;
                  if (isDesktop) {
                    return _buildDesktopLayout(context, manga);
                  } else {
                    return _buildMobileLayout(context, manga);
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

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(BuildContext context, Manga manga) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildCoverImage(manga.imageUrl)),
          const SizedBox(height: 24),
          _buildInfoSection(context, manga),
        ],
      ),
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(BuildContext context, Manga manga) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverImage(manga.imageUrl),
          const SizedBox(width: 32),
          Expanded(child: _buildInfoSection(context, manga)),
        ],
      ),
    );
  }

  // --- WIDGET COVER ---
  Widget _buildCoverImage(String coverUrl) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 200,
        height: 300,
        child: Image.network(
          coverUrl, // URL sudah aman (diproyeksi di Model)
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 40, color: Colors.grey),
                Text("No Image", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  // --- WIDGET INFO + CHAPTER LIST ---
  Widget _buildInfoSection(BuildContext context, Manga manga) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul
        Text(
          manga.title,
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (manga.titleEnglish != null) ...[
          const SizedBox(height: 4),
          Text(
            manga.titleEnglish!,
            style: textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
        ],
        
        const SizedBox(height: 16),

        // Status & Type Badges
        Row(
          children: [
            if (manga.status != null) _buildBadge(context, manga.status!, Colors.green),
            if (manga.type != null) ...[
              const SizedBox(width: 8),
              _buildBadge(context, manga.type!, Colors.blue),
            ],
          ],
        ),

        const SizedBox(height: 24),

        // Genres
        Text('Genres', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: manga.genres.map((genre) => Chip(
            label: Text(genre),
            padding: const EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
          )).toList(),
        ),

        const SizedBox(height: 24),

        // Sinopsis
        Text('Sinopsis', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          manga.synopsis ?? 'Tidak ada deskripsi.',
          style: textTheme.bodyLarge?.copyWith(height: 1.5),
        ),

        const SizedBox(height: 24),
        const Divider(thickness: 1, color: Colors.white24),
        const SizedBox(height: 16),
        
        // --- BAGIAN LIST CHAPTER (BARU) ---
        Text(
          'Daftar Chapter (${manga.chapterList.length})', 
          style: textTheme.titleLarge
        ),
        const SizedBox(height: 12),

        if (manga.chapterList.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Belum ada chapter yang tersedia.", 
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
            ),
          )
        else
          ListView.builder(
            // Penting: shrinkWrap & physics agar bisa scroll di dalam SingleChildScrollView
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(),
            itemCount: manga.chapterList.length,
            itemBuilder: (context, index) {
              final chapter = manga.chapterList[index];
              return Card(
                color: Colors.grey.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Text(
                    chapter['title'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: chapter['date'] != null 
                    ? Text(chapter['date'], style: const TextStyle(fontSize: 12)) 
                    : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
                  onTap: () {
                  print("Navigasi ke chapter ID: ${chapter['id']}");
                    context.push('/read/${chapter['id']}');
                  },
                ),
              );
            },
          ),
          
        const SizedBox(height: 40), // Jarak bawah biar tidak kepotong
      ],
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}