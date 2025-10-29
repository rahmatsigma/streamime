// lib/presentation/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/favorite_cubit.dart';
import 'detail_screen.dart'; // Untuk navigasi saat di-klik

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      // Kita gunakan BlocBuilder untuk mendengarkan FavoriteCubit
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          
          // --- KONDISI 1: Jika Favorit Kosong ---
          if (state.favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // --- KONDISI 2: Jika Ada Favorit ---
          return ListView.builder(
            itemCount: state.favorites.length,
            itemBuilder: (context, index) {
              // Ambil anime dari state
              final anime = state.favorites[index];
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Image.network(
                    anime.imageUrl,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                  title: Text(anime.title),
                  subtitle: Text('Score: ${anime.score.toString()}'),
                  
                  // Aksi saat di-klik: Pergi ke DetailScreen
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          animeId: anime.id,
                          animeTitle: anime.title,
                        ),
                      ),
                    );
                  },

                  // Aksi trailing: Tombol untuk Hapus
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_forever, // Ikon tong sampah
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      // Panggil cubit untuk menghapus
                      context.read<FavoriteCubit>().toggleFavorite(anime);
                      
                      // Tampilkan snackbar konfirmasi
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
            },
          );
        },
      ),
    );
  }
}