import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/logic/manga_list_cubit.dart';
import 'package:manga_read/features/home/logic/manga_list_state.dart';
import 'package:manga_read/features/home/presentation/widgets/manga_grid_card.dart';
import 'package:sizer/sizer.dart';

enum _ProfileMenuAction { favorites, history, settings, logout }

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
  final List<String> _favoriteManga = [
    'Solo Leveling',
    'Jujutsu Kaisen',
    'One Piece',
  ];
  final List<String> _readingHistory = [
    'Blue Lock - Ch. 224',
    'Chainsaw Man - Ch. 146',
    'Spy x Family - Ch. 88',
  ];
  bool _isLoggedIn = false;

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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white70, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari manga...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white60),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
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
        toolbarHeight: 96,
        centerTitle: false,
        titleSpacing: 16,
        // Tampilkan search bar atau judul biasa, tergantung state
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: _isSearching
              ? _buildSearchBar()
              : const Text(
                  'MangaRead - Populer',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
              ),
              child: IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                tooltip: _isSearching ? 'Tutup pencarian' : 'Cari manga',
                onPressed: _toggleSearch,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: _buildProfileMenu(),
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

  Widget _buildProfileMenu() {
    return PopupMenuButton<_ProfileMenuAction>(
      tooltip: 'Buka menu profil',
      offset: const Offset(0, 48),
      elevation: 6,
      color: const Color(0xFF1F1F24),
      constraints: const BoxConstraints(minWidth: 260),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: _handleProfileMenuSelection,
      itemBuilder: (context) {
        final entries = <PopupMenuEntry<_ProfileMenuAction>>[
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.favorites,
            child: _buildMenuTile(
              icon: Icons.favorite_border,
              title: 'Favorite',
              subtitle: !_isLoggedIn
                  ? 'Login untuk menyimpan favorite.'
                  : _favoriteManga.isEmpty
                      ? 'Belum ada manga favorit.'
                      : 'Terakhir: ${_favoriteManga.first}',
            ),
          ),
          const PopupMenuDivider(height: 12),
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.history,
            child: _buildMenuTile(
              icon: Icons.history,
              title: 'History Baca',
              subtitle: !_isLoggedIn
                  ? 'Login untuk melihat history.'
                  : _readingHistory.isEmpty
                      ? 'Belum ada history.'
                      : 'Terakhir: ${_readingHistory.first}',
            ),
          ),
          const PopupMenuDivider(height: 12),
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.settings,
            child: _buildMenuTile(
              icon: Icons.settings,
              title: 'Setting',
              subtitle: 'Atur preferensi aplikasi',
            ),
          ),
        ];

        if (_isLoggedIn) {
          entries.addAll([
            const PopupMenuDivider(height: 12),
            PopupMenuItem<_ProfileMenuAction>(
              value: _ProfileMenuAction.logout,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Keluar dari akun ini',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]);
        }

        return entries;
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white.withOpacity(0.15),
        child: const Icon(Icons.person, color: Colors.white),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _ensureLoggedIn() async {
    if (_isLoggedIn) return true;

    final goToLogin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Butuh Login'),
        content: const Text(
          'Fitur ini hanya tersedia untuk pengguna yang sudah login. '
          'Masuk sekarang untuk mengakses favorit dan history bacaanmu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ke Halaman Login'),
          ),
        ],
      ),
    );

    if (goToLogin == true) {
      if (!mounted) return false;
      final loginSuccess = await context.push<bool>('/login');
      if (!mounted) return false;
      if (loginSuccess == true) {
        setState(() {
          _isLoggedIn = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login berhasil.')),
        );
        return true;
      }
    }

    return false;
  }

  void _handleProfileMenuSelection(_ProfileMenuAction action) async {
    switch (action) {
      case _ProfileMenuAction.favorites:
        if (!await _ensureLoggedIn()) return;
        if (!mounted) return;
        context.push(
          '/favorites',
          extra: List<String>.from(_favoriteManga),
        );
        break;
      case _ProfileMenuAction.history:
        if (!await _ensureLoggedIn()) return;
        if (!mounted) return;
        context.push(
          '/history',
          extra: {
            'history': List<String>.from(_readingHistory),
            'isLoggedIn': _isLoggedIn,
          },
        );
        break;
      case _ProfileMenuAction.settings:
        if (!mounted) return;
        context.push('/settings');
        break;
      case _ProfileMenuAction.logout:
        setState(() {
          _isLoggedIn = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil logout.')),
        );
        break;
    }
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
