import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/logic/manga_list_cubit.dart';
import 'package:manga_read/features/home/logic/manga_list_state.dart';
import 'package:manga_read/features/home/presentation/widgets/manga_grid_card.dart';
// import 'package:manga_read/core/image_proxy.dart'; // Tidak wajib dipakai di sini lagi
import 'package:sizer/sizer.dart';

// --- IMPORT FIREBASE AUTH ---
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/auth/logic/auth_state.dart';

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

  // Data dummy (Nanti diganti logic backend)
  final List<String> _favoriteManga = [
    'Solo Leveling',
    'Jujutsu Kaisen',
  ];
  final List<String> _readingHistory = [
    'Blue Lock - Ch. 224',
    'Chainsaw Man - Ch. 146',
  ];

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

    if (!_isSearching && _searchController.text.isNotEmpty) {
      _searchController.clear();
      // Reset pencarian jika ditutup (opsional, bisa load ulang popular)
      // context.read<MangaListCubit>().getPopularManga(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan AuthCubit untuk cek status login
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final bool isLoggedIn = authState.status == AuthStatus.authenticated;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 96,
            centerTitle: false,
            titleSpacing: 16,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _isSearching
                  ? _buildSearchBar()
                  : const Text(
                      'MangaRead - Populer',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
            ),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
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
                padding:
                    const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
                child: _buildProfileMenu(isLoggedIn),
              ),
            ],
          ),
          body: BlocBuilder<MangaListCubit, MangaListState>(
            builder: (context, state) {
              if (state is MangaListLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MangaListError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              if (state is MangaListLoaded) {
                if (state.mangaList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada manga ditemukan.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                return _buildResponsiveGrid(
                  state.mangaList,
                  state.isLoadingMore,
                  state.hasReachedMax,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileMenu(bool isLoggedIn) {
    return PopupMenuButton<_ProfileMenuAction>(
      tooltip: 'Buka menu profil',
      offset: const Offset(0, 48),
      elevation: 6,
      color: const Color(0xFF1F1F24),
      constraints: const BoxConstraints(minWidth: 260),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (action) => _handleProfileMenuSelection(action, isLoggedIn),
      itemBuilder: (context) {
        final entries = <PopupMenuEntry<_ProfileMenuAction>>[
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.favorites,
            child: _buildMenuTile(
              icon: Icons.favorite_border,
              title: 'Favorite',
              subtitle: !isLoggedIn
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
              subtitle: !isLoggedIn
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

        if (isLoggedIn) {
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
                    child: const Icon(Icons.logout,
                        color: Colors.redAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Butuh Login'),
        content: const Text(
          'Fitur ini hanya tersedia untuk pengguna yang sudah login. '
          'Masuk sekarang untuk mengakses favorit dan history bacaanmu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.push('/login');
            },
            child: const Text('Ke Halaman Login'),
          ),
        ],
      ),
    );
  }

  void _handleProfileMenuSelection(
      _ProfileMenuAction action, bool isLoggedIn) {
    if (action == _ProfileMenuAction.favorites ||
        action == _ProfileMenuAction.history) {
      if (!isLoggedIn) {
        _showLoginDialog();
        return;
      }
    }

    switch (action) {
      case _ProfileMenuAction.favorites:
        context.push(
          '/favorites',
          extra: {
            'favorites': List<String>.from(_favoriteManga),
            'isLoggedIn': isLoggedIn,
          },
        );
        break;
      case _ProfileMenuAction.history:
        context.push(
          '/history',
          extra: {
            'history': List<String>.from(_readingHistory),
            'isLoggedIn': isLoggedIn,
          },
        );
        break;
      case _ProfileMenuAction.settings:
        context.push('/settings');
        break;
      case _ProfileMenuAction.logout:
        context.read<AuthCubit>().signOut();
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
        if (deviceType == DeviceType.mobile) {
          crossAxisCount = 2;
        } else if (deviceType == DeviceType.tablet) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 5;
        }

        final int itemCount = isLoadingMore && !hasReachedMax
            ? mangaList.length + 1
            : mangaList.length;

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
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading..."),
                ],
              );
            }

            final manga = mangaList[index];
            final String title = manga['title'];
            
            // Variabel ini sudah berisi URL Proxy dari Repository (impl.dart)
            final String coverUrl = manga['coverUrl']; 
            final String mangaId = manga['id'];

            return GestureDetector(
              onTap: () {
                print("ID YANG DIKIRIM: $mangaId");
                final safeId = Uri.encodeComponent(mangaId);
                
                context.push('/manga-detail/$safeId');
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