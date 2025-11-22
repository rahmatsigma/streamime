import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/chapter_read/logic/chapter_read_cubit.dart';
import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:manga_read/core/image_proxy.dart'; // WAJIB PAKAI PROXY

class ChapterReadPage extends StatelessWidget {
  final String chapterId;

  const ChapterReadPage({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChapterReadCubit(
        context.read<IMangaRepository>(),
      )..getImages(chapterId),
      child: Scaffold(
        backgroundColor: Colors.black, // Background hitam biar enak baca
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          title: const Text("Reader"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<ChapterReadCubit, ChapterReadState>(
          builder: (context, state) {
            if (state is ChapterReadLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChapterReadError) {
              return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.white)));
            }
            if (state is ChapterReadLoaded) {
              if (state.images.isEmpty) {
                return const Center(child: Text("Tidak ada gambar di chapter ini.", style: TextStyle(color: Colors.white)));
              }

              return ListView.builder(
                itemCount: state.images.length,
                // CacheExtent: Preload gambar di bawahnya biar ga loading pas scroll
                cacheExtent: 3000, 
                itemBuilder: (context, index) {
                  final url = state.images[index];
                  return Image.network(
                    ImageProxy.proxy(url), // PROXY WAJIB DI WEB
                    fit: BoxFit.fitWidth, // Lebar menyesuaikan layar
                    width: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 200,
                      child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}