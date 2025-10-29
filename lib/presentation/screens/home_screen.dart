// lib/presentation/screens/home_screen.dart

import 'dart:async'; // <-- Untuk Timer (Debounce)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/favorite_cubit.dart'; // <-- Import Favorite Cubit
import '../../logic/cubit/top_anime_cubit.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Controller untuk Pagination / Infinite Scroll
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Panggil top anime saat pertama kali load
    context.read<TopAnimeCubit>().fetchTopAnime();

    // Tambahkan Listener untuk Scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Hapus semua controller dan timer
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // Fungsi Listener Scroll
  void _onScroll() {
    // Cek jika kita ada di paling bawah
    // dikurangi 200px agar load sebelum mentok
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) { 
      // Panggil fungsi loadMore di Cubit
      context.read<TopAnimeCubit>().loadMore();
    }
  }
  
  // Fungsi Debounce untuk Search
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
        title: const Text('Anime Jikan'),
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
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
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
          
          // --- HASIL LIST ---
          Expanded(
            child: BlocBuilder<TopAnimeCubit, TopAnimeState>(
              builder: (context, state) {
                
                // --- Loading State (Awal) ---
                if (state is TopAnimeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // --- Error State ---
                if (state is TopAnimeError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // --- Success State (State Utama) ---
                if (state is TopAnimeSuccess) {
                  if (state.animeList.isEmpty) {
                    return const Center(child: Text('No anime found.'));
                  }

                  return ListView.builder(
                    // Pasang ScrollController
                    controller: _scrollController,
                    
                    // Tambah 1 item untuk loading indicator
                    itemCount: state.hasReachedMax 
                        ? state.animeList.length 
                        : state.animeList.length + 1,
                        
                    itemBuilder: (context, index) {
                      // Cek apakah ini item terakhir
                      if (index >= state.animeList.length) {
                        // Ini adalah item loading indicator
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      // Ini adalah item anime
                      final anime = state.animeList[index];
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

                          // --- TOMBOL FAVORIT ---
                          trailing: BlocBuilder<FavoriteCubit, FavoriteState>(
                            builder: (context, favoriteState) {
                              final isFav = context.read<FavoriteCubit>().isFavorite(anime.id);
                              return IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : null,
                                ),
                                onPressed: () {
                                  // Kirim AnimeModel lengkap ke cubit
                                  context.read<FavoriteCubit>().toggleFavorite(anime);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }

                // --- Initial State (Default) ---
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