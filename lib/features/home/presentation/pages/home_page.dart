import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/data/repositories/manga_repository_impl.dart';
import 'package:manga_read/features/home/logic/manga_list_cubit.dart';
import 'package:manga_read/features/home/logic/manga_list_state.dart';
import 'package:manga_read/features/home/presentation/widgets/manga_grid_card.dart';
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/auth/logic/auth_state.dart';
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

  // --- WIDGET SEARCH BAR ---
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
                  isDense: true,
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

    if (!_isSearching) {
      _searchController.clear();
      context.read<MangaListCubit>().getPopularManga(page: 1);
    }
  }

  // --- WIDGET LANJUTKAN MEMBACA ---
  Widget _buildContinueReading(String? userId) {
    if (userId == null) return const SizedBox.shrink();

    final repo = context.read<IMangaRepository>() as MangaRepositoryImpl;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: repo.getHistoryStream(userId).map((list) => list.take(1).toList()),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final history = snapshot.data!.first;
        final String chapterId = history['chapterId'] ?? '';
        
        if (chapterId.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.fromLTRB(3.w, 2.w, 3.w, 2.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Lanjutkan Membaca",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  context.push('/read/$chapterId');
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          history['coverUrl'], 
                          width: 80,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_,__,___) => Container(width: 80, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                history['title'] ?? 'Manga',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                history['lastChapter'] ?? 'Chapter ?',
                                style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Ketuk untuk lanjut baca",
                                style: TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(Icons.play_circle_fill, size: 40, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final bool isLoggedIn = authState.status == AuthStatus.authenticated;
    final String? userId = authState.user?.uid;
    
    String displayName = authState.user?.displayName ?? 'User';
    if (displayName.contains(' ')) {
      displayName = displayName.split(' ')[0]; 
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 96,
        centerTitle: false,
        titleSpacing: 16,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: _isSearching
              ? _buildSearchBar()
              : Row(
                  children: [
                    Text(
                      isMobile && isLoggedIn ? 'MangaRead' : 'MangaRead - Populer',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    if (isLoggedIn) ...[
                      const Spacer(), 
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 16, 
                          vertical: 6
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              isMobile ? 'Hai, ' : 'Selamat datang, ',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                color: Colors.white54,
                              ),
                            ),
                            Text(
                              '$displayName 👋',
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 16, 
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(), 
                    ] else ...[
                      const Spacer(), 
                    ]
                  ],
                ),
        ),
        actions: [
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Cari manga',
                  onPressed: _toggleSearch,
                ),
              ),
            ),
          if (_isSearching)
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  tooltip: 'Tutup pencarian',
                  onPressed: _toggleSearch,
                ),
              ),
            ),

          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: _buildProfileMenu(isLoggedIn),
          ),
        ],
      ),
      
      // --- PERBAIKAN LOGIKA STATE ---
      body: BlocBuilder<MangaListCubit, MangaListState>(
        builder: (context, state) {
          // 1. LOADING: Kalau lagi loading dan kita TIDAK sedang punya data
          //    (biasanya loading awal), tampilkan spinner.
          if (state is MangaListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 2. ERROR: Kalau error, tampilkan pesan
          if (state is MangaListError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          // 3. LOADED: Ini satu-satunya state yang punya data 'mangaList'
          //    Kita deklarasikan variabel di sini biar aman
          List<dynamic> mangaList = [];
          bool isLoadingMore = false;

          if (state is MangaListLoaded) {
            mangaList = state.mangaList;
            isLoadingMore = state.isLoadingMore;
          } else {
            // Fallback kalau state aneh (Initial, dll), list kosong
            mangaList = [];
          }

          return RefreshIndicator(
            onRefresh: () async {
               if (_isSearching) {
                  await context.read<MangaListCubit>().searchManga(_searchController.text);
                } else {
                  await context.read<MangaListCubit>().getPopularManga(page: 1);
                }
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header Lanjutkan Membaca
                if (!_isSearching)
                  SliverToBoxAdapter(
                    child: _buildContinueReading(userId),
                  ),

                // Grid Manga
                if (mangaList.isEmpty) 
                   const SliverToBoxAdapter(
                     child: SizedBox(
                       height: 200,
                       child: Center(child: Text("Tidak ada data ditemukan.")),
                     ),
                   )
                else
                  SliverPadding(
                    padding: EdgeInsets.all(3.w),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 5),
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 3.w,
                        mainAxisSpacing: 3.w,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final manga = mangaList[index];
                          return GestureDetector(
                            onTap: () => context.push('/manga-detail/${manga['id']}'),
                            child: MangaGridCard(
                              key: ValueKey(manga['id']),
                              title: manga['title'],
                              coverUrl: manga['coverUrl'],
                            ),
                          );
                        },
                        childCount: mangaList.length,
                      ),
                    ),
                  ),

                // Loading Bawah (Pagination)
                if (isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
        final List<PopupMenuEntry<_ProfileMenuAction>> entries = [];

        entries.add(
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.favorites,
            child: _buildMenuTile(
              icon: Icons.favorite_border,
              title: 'Favorite',
              subtitle: !isLoggedIn
                  ? 'Login untuk melihat favorit.'
                  : 'Lihat koleksi favoritmu',
            ),
          ),
        );

        entries.add(const PopupMenuDivider(height: 12));

        entries.add(
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.history,
            child: _buildMenuTile(
              icon: Icons.history,
              title: 'History Baca',
              subtitle: !isLoggedIn
                  ? 'Login untuk melihat history.'
                  : 'Lanjutkan bacaan terakhir',
            ),
          ),
        );

        entries.add(const PopupMenuDivider(height: 12));

        entries.add(
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.settings,
            child: _buildMenuTile(
              icon: Icons.settings,
              title: 'Setting',
              subtitle: 'Atur preferensi aplikasi',
            ),
          ),
        );

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

  // --- Dialog Login ---
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

  // --- Dialog Logout ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah kamu yakin ingin keluar dari akun ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Berhasil logout.')),
              );
            },
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }

  void _handleProfileMenuSelection(_ProfileMenuAction action, bool isLoggedIn) {
    if (action == _ProfileMenuAction.favorites ||
        action == _ProfileMenuAction.history) {
      if (!isLoggedIn) {
        _showLoginDialog();
        return;
      }
    }

    switch (action) {
      case _ProfileMenuAction.favorites:
        context.push('/favorites');
        break;
      case _ProfileMenuAction.history:
        context.push('/history');
        break;
      case _ProfileMenuAction.settings:
        context.push('/settings');
        break;
      case _ProfileMenuAction.logout:
        // Pakai dialog logout yang baru
        _showLogoutDialog();
        break;
    }
  }
}