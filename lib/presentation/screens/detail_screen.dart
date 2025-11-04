// lib/presentation/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/anime_model.dart';
import '../../data/repositories/anime_repository.dart';
import '../../logic/cubit/anime_detail_cubit.dart';
import '../../logic/cubit/favorite_cubit.dart';

class DetailScreen extends StatelessWidget {
  final int animeId;
  final String animeTitle;

  const DetailScreen({
    super.key,
    required this.animeId,
    required this.animeTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnimeDetailCubit(
        context.read<AnimeRepository>(),
      )..fetchAnimeDetail(animeId), 
      
      child: BlocBuilder<AnimeDetailCubit, AnimeDetailState>(
        builder: (context, state) {
          
          final String title = (state is AnimeDetailSuccess) ? state.anime.title : animeTitle;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: (){
                  context.go('/HomeScreen');
                }
              ),
              title: Text(title),
              actions: [
                if (state is AnimeDetailSuccess)
                  BlocBuilder<FavoriteCubit, FavoriteState>(
                    builder: (context, favoriteState) {
                      final bool isFav = context.read<FavoriteCubit>().isFavorite(state.anime.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : null,
                        ),
                        onPressed: () {
                          final animeAsModel = AnimeModel(
                            id: state.anime.id, 
                            title: state.anime.title, 
                            imageUrl: state.anime.imageUrl, 
                            score: state.anime.score
                          );
                          context.read<FavoriteCubit>().toggleFavorite(animeAsModel);
                        },
                      );
                    },
                  )
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  // --- SELURUH BODY DI-UPDATE DENGAN SIZER ---
  Widget _buildBody(BuildContext context, AnimeDetailState state) {
    if (state is AnimeDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AnimeDetailSuccess) {
      final anime = state.anime;
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1120), Color(0xFF1A1036)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w), // 16.0 -> 4.w
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Hero(
                  tag: 'anime-${anime.id}',
                  child: Image.network(
                    anime.imageUrl,
                    height: 40.h, // 300 -> 40.h (40% tinggi layar)
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 40.h),
                  ),
                ),
              ),
              SizedBox(height: 2.h), // 16.0 -> 2.h
              Text(
                anime.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp, // Ukuran font responsif
                    ),
              ),
              SizedBox(height: 1.h), // 8.0 -> 1.h
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoChip(
                    icon: Icons.star,
                    text: '${anime.score} / 10',
                    color: Colors.amber,
                  ),
                  InfoChip(
                    icon: Icons.tv,
                    text: '${anime.episodes ?? '?'} episodes',
                    color: Colors.cyan,
                  ),
                  InfoChip(
                    icon: Icons.info_outline,
                    text: anime.status,
                    color: Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              const Divider(),
              SizedBox(height: 2.h),
              Text(
                'Synopsis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16.sp, // Ukuran font responsif
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                anime.synopsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp, // Ukuran font responsif
                  height: 1.5, // Jarak antar baris
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      );
    }

    if (state is AnimeDetailError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }
    
    return const Center(child: Text('Loading details...'));
  }
}

// --- InfoChip JUGA DI-UPDATE ---
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: color, size: 14.sp), // 20 -> 14.sp
      label: Text(
        text,
        style: TextStyle(fontSize: 11.sp), // Ukuran font responsif
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
    );
  }
}
