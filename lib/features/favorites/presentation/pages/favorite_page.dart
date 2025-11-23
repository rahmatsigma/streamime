import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/core/image_proxy.dart';
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/auth/logic/auth_state.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/data/repositories/manga_repository_impl.dart';
import 'package:manga_read/models/manga.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil status login & Repository
    final authState = context.watch<AuthCubit>().state;
    final isLoggedIn = authState.status == AuthStatus.authenticated;
    final userId = authState.user?.uid;
    final repo = context.read<IMangaRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manga Favorit')),
      body: !isLoggedIn || userId == null
          ? _buildLoginPrompt(context)
          : StreamBuilder<List<Manga>>(
              // 2. Panggil Stream dari Repository
              // (Kita cast ke Impl karena fungsi stream ada di sana)
              stream: (repo as MangaRepositoryImpl).getFavoritesStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                
                final favorites = snapshot.data ?? [];

                if (favorites.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Belum ada favorit.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // 3. Tampilkan List
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final manga = favorites[index];
                    return _buildFavoriteItem(context, manga);
                  },
                );
              },
            ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, Manga manga) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/manga-detail/${manga.id}'),
        child: Row(
          children: [
            // Gambar Kecil
            SizedBox(
              width: 80,
              height: 120,
              child: Image.network(
                // Gunakan Proxy agar gambar aman
                ImageProxy.proxy(manga.imageUrl), 
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (manga.type != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        manga.type!,
                        style: const TextStyle(color: Colors.blue, fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Login untuk melihat favorit.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            child: const Text('Login Sekarang'),
          ),
        ],
      ),
    );
  }
}