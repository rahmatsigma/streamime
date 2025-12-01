import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/core/image_proxy.dart';
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/auth/logic/auth_state.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/features/home/data/repositories/manga_repository_impl.dart';

class ReadingHistoryPage extends StatelessWidget {
  const ReadingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isLoggedIn = authState.status == AuthStatus.authenticated;
    final userId = authState.user?.uid;
    final repo = context.read<IMangaRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('History Baca')),
      body: !isLoggedIn || userId == null
          ? _buildLoginPrompt(context)
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: (repo as MangaRepositoryImpl).getHistoryStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final historyList = snapshot.data ?? [];

                if (historyList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada history baca.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: historyList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = historyList[index];
                    return _buildHistoryItem(context, data);
                  },
                );
              },
            ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> data) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // --- LOGIC NAVIGASI ---
          final String? chapterId = data['chapterId'];
          final String mangaId = data['mangaId'];

          if (chapterId != null && chapterId.isNotEmpty) {
            print("Lanjut baca chapter: $chapterId");
            context.push('/read/$chapterId');
          } else {
            print("Data lama/tidak lengkap, buka detail manga: $mangaId");
            context.push('/manga-detail/$mangaId');
          }
        },
        child: Row(
          children: [
            // Gambar Kecil
            SizedBox(
              width: 80,
              height: 100,
              child: Image.network(
                ImageProxy.proxy(data['coverUrl']),
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
                    data['title'] ?? 'Tanpa Judul',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Terakhir: ${data['lastChapter'] ?? '-'}",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tombol Play di Kanan (Shortcut)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  size: 32,
                  color: Colors.blue,
                ),
                onPressed: () {
                  // Logic sama persis dengan onTap
                  final String? chapterId = data['chapterId'];
                  if (chapterId != null && chapterId.isNotEmpty) {
                    context.push('/read/$chapterId');
                  } else {
                    context.push('/manga-detail/${data['mangaId']}');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => context.push('/login'),
        child: const Text('Login Sekarang'),
      ),
    );
  }
}
