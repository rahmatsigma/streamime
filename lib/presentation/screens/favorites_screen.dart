// lib/presentation/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // <-- Import GoRouter
import 'package:sizer/sizer.dart'; // <-- Import Sizer
import '../../data/models/anime_model.dart'; // <-- Perlu untuk widget Card
import '../../logic/cubit/favorite_cubit.dart';
// (import detail_screen.dart tidak perlu di sini)

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1120), Color(0xFF1A1036)],
          ),
        ),
        child: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          
          // --- KONDISI 1: Jika Favorit Kosong ---
          if (state.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 20.w, color: Colors.grey),
                  SizedBox(height: 2.h),
                  Text(
                    'No favorites yet.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // --- KONDISI 2: Jika Ada Favorit (Adaptif) ---
          return LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600;

              if (isWide) {
                // --- TAMPILAN LEBAR (GRID VIEW) ---
                int crossAxisCount = (constraints.maxWidth / 250).floor();
                
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 2.w,
                    mainAxisSpacing: 2.w,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final anime = state.favorites[index];
                    // Tampilkan item sebagai Grid Card
                    return _FavoriteGridCard(anime: anime);
                  },
                );
              } else {
                // --- TAMPILAN SEMPIT (LIST VIEW) ---
                return ListView.builder(
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final anime = state.favorites[index];
                    // Tampilkan item sebagai List Tile
                    return _FavoriteListTile(anime: anime);
                  },
                );
              }
            }
          );
        },
      ),
      ),
    );
  }
}

// --- WIDGET BARU (PRIVATE) UNTUK LIST TILE FAVORIT ---
class _FavoriteListTile extends StatelessWidget {
  final AnimeModel anime;
  const _FavoriteListTile({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
      child: ListTile(
        contentPadding: EdgeInsets.all(2.w),
        leading: Hero(
          tag: 'anime-${anime.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              anime.imageUrl,
              width: 14.w,
              height: 14.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ),
          ),
        ),
        title: Text(anime.title),
        subtitle: Text('Score: ${anime.score.toString()}'),
        onTap: () {
          context.go('/detail/${anime.id}', extra: anime.title);
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
          onPressed: () {
            context.read<FavoriteCubit>().toggleFavorite(anime);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${anime.title} removed from favorites'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- WIDGET BARU (PRIVATE) UNTUK GRID CARD FAVORIT ---
// --- WIDGET BARU (PRIVATE) UNTUK GRID CARD FAVORIT ---
class _FavoriteGridCard extends StatelessWidget {
  final AnimeModel anime;
  const _FavoriteGridCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Konten
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- PERBAIKAN MULAI DI SINI ---
              Expanded(
                child: Hero(
                  tag: 'anime-${anime.id}',
                  child: Image.network(
                    anime.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                      color: Colors.grey[850],
                      child: Center(
                        child: Icon(Icons.broken_image, size: 8.w),
                      ),
                    ),
                  ),
                ),
              ),
              // --- PERBAIKAN SELESAI ---

              Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Score: ${anime.score.toString()}',
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Tombol tap (full)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.go('/detail/${anime.id}', extra: anime.title);
                },
              ),
            ),
          ),
          // Tombol Hapus (kanan atas)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.7),
              ),
              onPressed: () {
                context.read<FavoriteCubit>().toggleFavorite(anime);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${anime.title} removed from favorites'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
