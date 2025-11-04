import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../data/models/anime_model.dart'; 
import '../../logic/cubit/favorite_cubit.dart';
import '../../logic/cubit/top_anime_cubit.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TopAnimeCubit>().fetchTopAnime();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) { 
      context.read<TopAnimeCubit>().loadMore();
    }
  }
  
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<TopAnimeCubit>().searchAnime(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streamimer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              context.read<TopAnimeCubit>().fetchTopAnime();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- SEARCH BAR (Sizer) ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: (){
                    _searchController.clear();
                    context.read<TopAnimeCubit>().fetchTopAnime();
                  },
                )
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          Expanded(
            child: BlocBuilder<TopAnimeCubit, TopAnimeState>(
              builder: (context, state) {
              
                if (state is TopAnimeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TopAnimeError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // --- INI BAGIAN UTAMANYA ---
                if (state is TopAnimeSuccess) {
                  if (state.animeList.isEmpty) {
                    return const Center(child: Text('No anime found.'));
                  }

                  // --- GUNAKAN LAYOUTBUILDER UNTUK CEK LEBAR ---
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Tentukan breakpoint. 600px adalah standar tablet
                      bool isWide = constraints.maxWidth > 600; 

                      if (isWide) {
                        int crossAxisCount = (constraints.maxWidth / 250).floor();
                        
                        return GridView.builder(
                          controller: _scrollController, // Controller tetap sama
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.65, // Rasio item (sesuaikan)
                            crossAxisSpacing: 2.w,
                            mainAxisSpacing: 2.w,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          itemCount: state.hasReachedMax 
                              ? state.animeList.length 
                              : state.animeList.length + 1,
                          itemBuilder: (context, index) {
                            if (index >= state.animeList.length) {
                              // Loading indicator di paling bawah
                              return const Center(child: CircularProgressIndicator());
                            }
                            final anime = state.animeList[index];
                            // Tampilkan item sebagai Grid Card
                            return _AnimeGridCard(anime: anime);
                          },
                        );
                      } else {
                        // --- TAMPILAN SEMPIT (LIST VIEW) ---
                        // Ini adalah kode ListView kita sebelumnya
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: state.hasReachedMax 
                              ? state.animeList.length 
                              : state.animeList.length + 1,
                          itemBuilder: (context, index) {
                            if (index >= state.animeList.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final anime = state.animeList[index];
                            // Tampilkan item sebagai List Tile
                            return _AnimeListTile(anime: anime);
                          },
                        );
                      }
                    },
                  );
                }

                return const Center(
                  child: Text('Press refresh button to load anime.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET BARU (PRIVATE) UNTUK LIST TILE ---
// Kita pisahkan agar rapi
class _AnimeListTile extends StatelessWidget {
  final AnimeModel anime;
  const _AnimeListTile({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
      child: ListTile(
        leading: Image.network(
          anime.imageUrl,
          width: 14.w,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
        ),
        title: Text(anime.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('Score: ${anime.score.toString()}'),
        onTap: () {
          context.go('/detail/${anime.id}', extra: anime.title);
        },
        trailing: BlocBuilder<FavoriteCubit, FavoriteState>(
          builder: (context, favoriteState) {
            final isFav = context.read<FavoriteCubit>().isFavorite(anime.id);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : null,
              ),
              onPressed: () {
                context.read<FavoriteCubit>().toggleFavorite(anime);
              },
            );
          },
        ),
      ),
    );
  }
}

class _AnimeGridCard extends StatelessWidget {
  final AnimeModel anime;
  const _AnimeGridCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Biar gambar rapi
      child: Stack(
        children: [
          // Konten utama
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  anime.imageUrl,
                  // HAPUS height: 25.h
                  fit: BoxFit.cover, // fit: cover penting
                  errorBuilder: (context, error, stackTrace) =>
                      // Ganti SizedBox dengan Container/Icon di tengah
                      Container(
                    color: Colors.grey[850],
                    child: Center(
                      child: Icon(Icons.broken_image, size: 8.w),
                    ),
                  ),
                ),
              ),
              // --- PERBAIKAN SELESAI ---
              
              // Judul & Score
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
          // Tombol favorit (kanan atas)
          Positioned(
            top: 0,
            right: 0,
            child: BlocBuilder<FavoriteCubit, FavoriteState>(
              builder: (context, favoriteState) {
                final isFav = context.read<FavoriteCubit>().isFavorite(anime.id);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    context.read<FavoriteCubit>().toggleFavorite(anime);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
