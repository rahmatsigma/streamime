import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/logic/manga_list_cubit.dart';
import 'package:manga_read/features/home/logic/manga_list_state.dart';
import 'package:manga_read/features/home/presentation/widgets/manga_grid_card.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce; 
  bool _isSearching = false; 

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MangaListCubit>().loadMoreManga();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      final query = _searchController.text;
      context.read<MangaListCubit>().searchManga(query);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    
    super.dispose();
  }

  String _getBestTitle(dynamic mangaData) {
    try {
      final attributes = mangaData['attributes'];
      if (attributes == null) return 'No Title (Attr Null)';
      final titleMap = attributes['title'] as Map<String, dynamic>?;
      if (titleMap == null || titleMap.isEmpty) return 'No Title (Map Null)';
      if (titleMap.containsKey('en')) return titleMap['en'];
      if (titleMap.containsKey('ja-ro')) return titleMap['ja-ro'];
      if (titleMap.containsKey('ja')) return titleMap['ja'];
      return titleMap.values.first;
    } catch (e) {
      return 'No Title (Error)';
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      autofocus: true, 
      decoration: const InputDecoration(
        hintText: 'Cari manga...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    // Jika kita menutup search, bersihkan text dan panggil ulang 'popular'
    if (!_isSearching && _searchController.text.isNotEmpty) {
      _searchController.clear(); // Ini akan otomatis trigger _onSearchChanged -> fetchPopularManga()
    }
  }
  // --- AKHIR FUNGSI BARU ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APPBAR BARU YANG DINAMIS ---
      appBar: AppBar(
        // Tampilkan search bar atau judul biasa, tergantung state
        title: _isSearching
            ? _buildSearchBar()
            : const Text('MangaRead - Populer'),
        actions: [
          // Tombol untuk toggle search
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      // --- AKHIR APPBAR BARU ---
      
      body: BlocBuilder<MangaListCubit, MangaListState>(
        builder: (context, state) {
          // --- PERUBAHAN LOGIKA LOADING ---
          // Kita tampilkan 'loading' hanya jika BUKAN state 'Loaded'
          // Ini mencegah 'pop-in' saat mengetik
          if (state is MangaListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MangaListError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is MangaListLoaded) {
            // Jika list kosong (setelah search), tampilkan pesan
            if (state.mangaList.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada manga ditemukan.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            
            // Render grid
            return _buildResponsiveGrid(
              state.mangaList,
              state.isLoadingMore,
              state.hasReachedMax,
            );
          }
          // Fallback untuk MangaListInitial
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildResponsiveGrid(
    MangaList mangaList,
    bool isLoadingMore,
    bool hasReachedMax,
  ) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        int crossAxisCount;
        if (deviceType == DeviceType.mobile)
          crossAxisCount = 2;
        else if (deviceType == DeviceType.tablet)
          crossAxisCount = 3;
        else
          crossAxisCount = 5;

        // Jangan tambahkan 1 jika 'hasReachedMax' (karena search)
        final int itemCount =
            isLoadingMore && !hasReachedMax ? mangaList.length + 1 : mangaList.length;

        return GridView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(2.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.7,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.w,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index >= mangaList.length) {
              // Spinner loading di bawah (hanya muncul jika 'isLoadingMore' true)
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading..."),
                ],
              );
            }

            // Kode render kartu manga (tidak berubah)
            final manga = mangaList[index];
            final String title = _getBestTitle(manga);
            String coverUrl = '';
            String mangaId = manga['id'];

            try {
              final coverRel = (manga['relationships'] as List<dynamic>)
                  .firstWhere((rel) => rel['type'] == 'cover_art');
              final String fileName = coverRel['attributes']['fileName'];
              coverUrl =
                  'https://uploads.mangadex.org/covers/$mangaId/$fileName.512.jpg';
            } catch (e) {
              coverUrl = 'placeholder_url_error';
            }

            return GestureDetector(
              onTap: () {
                context.push('/manga-detail/$mangaId');
              },
              child: MangaGridCard(
                key: ValueKey(mangaId),
                title: title,
                coverUrl: coverUrl,
              ),
            );
          },
        );
      },
    );
  }
}