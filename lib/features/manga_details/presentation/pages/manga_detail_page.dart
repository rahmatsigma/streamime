import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/auth/logic/auth_state.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/manga_details/logic/manga_detail_cubit.dart';
import 'package:manga_read/features/manga_details/logic/manga_detail_state.dart';
import 'package:manga_read/models/manga.dart';

class MangaDetailPage extends StatelessWidget {
  final String mangaId;
  const MangaDetailPage({super.key, required this.mangaId});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final String? userId = (authState.status == AuthStatus.authenticated) 
        ? authState.user?.uid 
        : null;

    return BlocProvider(
      create: (context) => MangaDetailCubit(
        context.read<IMangaRepository>(),
      )..getMangaDetail(mangaId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Manga'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          actions: [
            BlocBuilder<MangaDetailCubit, MangaDetailState>(
              builder: (context, state) {
                bool isFav = false;
                if (state is MangaDetailLoaded) {
                  isFav = state.isFavorite;
                }

                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.redAccent : null, 
                  ),
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    final isLoggedIn = authState.status == AuthStatus.authenticated;

                    if (isLoggedIn && authState.user != null) {
                      context.read<MangaDetailCubit>().toggleFavorite(authState.user!.uid);
                    } else {
                      _showLoginRequiredDialog(context);
                    }
                  },
                );
              },
            ),
            const SizedBox(width: 16),
          ],
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

              return LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 700;
                  if (isDesktop) {
                    return _buildDesktopLayout(context, manga, userId);
                  } else {
                    return _buildMobileLayout(context, manga, userId);
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

  Widget _buildMobileLayout(BuildContext context, Manga manga, String? userId) {
    final ScrollController scrollController = ScrollController();
    
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildCoverImage(manga.imageUrl)),
          const SizedBox(height: 24),
          _buildInfoSection(context, manga, userId, scrollController),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Manga manga, String? userId) {
    final ScrollController scrollController = ScrollController();
    
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverImage(manga.imageUrl),
          const SizedBox(width: 32),
          Expanded(child: _buildInfoSection(context, manga, userId, scrollController)),
        ],
      ),
    );
  }

  Widget _buildCoverImage(String coverUrl) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 200,
        height: 300,
        child: Image.network(
          coverUrl,
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

  Widget _buildInfoSection(BuildContext context, Manga manga, String? userId, ScrollController scrollController) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        Text('Sinopsis', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        if (manga.synopsis != null && manga.synopsis!.isNotEmpty)
          Text(
            manga.synopsis!,
            style: textTheme.bodyLarge?.copyWith(height: 1.5),
            textAlign: TextAlign.justify,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: const Column(
              children: [
                Icon(Icons.description_outlined, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Sinopsis belum tersedia untuk komik ini.',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

      const SizedBox(height: 24),
        const Divider(thickness: 1, color: Colors.white24),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Chapter (${manga.chapterList.length})', 
              style: textTheme.titleLarge
            ),
            if (manga.chapterList.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  // Scroll ke posisi maksimum (paling bawah)
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                label: const Text('Ke Chapter 1'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
          ],
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
                    context.read<MangaDetailCubit>().saveHistoryIfLoggedIn(
                      userId,
                      chapter['title'],
                      chapter['id'],
                    );

                    print("Navigasi ke chapter ID: ${chapter['id']}");
                    
                    context.push(
                      '/read/${chapter['id']}', 
                      extra: manga.chapterList, 
                    );
                  },
                ),
              );
            },
          ),
          
        const SizedBox(height: 40),
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

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Login Diperlukan"),
        content: const Text("Kamu harus login untuk menambahkan manga ke favorit."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/login');
            },
            child: const Text("Login Sekarang"),
          ),
        ],
      ),
    );
  }
}