// lib/presentation/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/anime_model.dart';
import '../../data/repositories/anime_repository.dart';
import '../../logic/cubit/anime_detail_cubit.dart';
import '../../logic/cubit/favorite_cubit.dart';

class DetailScreen extends StatelessWidget {
  final int animeId;
  final String animeTitle;

  const DetailScreen({
    Key? key,
    required this.animeId,
    required this.animeTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sediakan Cubit khusus untuk halaman ini
    return BlocProvider(
      create: (context) => AnimeDetailCubit(
        context.read<AnimeRepository>(),
      )..fetchAnimeDetail(animeId), // Langsung panggil fetch detail
      
      // Kita pakai BlocBuilder di root agar bisa update AppBar
      child: BlocBuilder<AnimeDetailCubit, AnimeDetailState>(
        builder: (context, state) {
          
          // Ambil judul dari state jika sukses, atau dari parameter jika loading
          final String title = (state is AnimeDetailSuccess) ? state.anime.title : animeTitle;

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: [
                // Hanya tampilkan tombol Hati jika data anime sudah loaded
                if (state is AnimeDetailSuccess)
                  // Gunakan BlocBuilder KEDUA khusus untuk FavoriteCubit
                  BlocBuilder<FavoriteCubit, FavoriteState>(
                    builder: (context, favoriteState) {
                      
                      final bool isFav = context.read<FavoriteCubit>().isFavorite(state.anime.id);

                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : null,
                        ),
                        onPressed: () {
                          // Buat AnimeModel sederhana dari AnimeDetailModel
                          // untuk disimpan ke Hive
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
            // Kirim state ke body
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  // Pisahkan body ke widget/fungsi sendiri agar lebih rapi
  Widget _buildBody(BuildContext context, AnimeDetailState state) {
    if (state is AnimeDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AnimeDetailSuccess) {
      final anime = state.anime;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                anime.imageUrl,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 150),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              anime.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Synopsis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              anime.synopsis,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      );
    }

    if (state is AnimeDetailError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }
    
    return const Center(child: Text('Loading details...'));
  }
}

// Widget helper kecil untuk info chip
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const InfoChip({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(text),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
    );
  }
}