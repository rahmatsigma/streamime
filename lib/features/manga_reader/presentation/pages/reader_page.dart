import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/manga_reader/data/repositories/reader_repository_impl.dart';
import 'package:manga_read/features/manga_reader/logic/reader_cubit.dart';
import 'package:manga_read/features/manga_reader/logic/reader_state.dart';

class ReaderPage extends StatelessWidget {
  final String chapterId;
  const ReaderPage({Key? key, required this.chapterId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReaderCubit(ReaderRepositoryImpl())
        ..fetchChapterPages(chapterId), // Langsung panggil fetch
      child: Scaffold(
        // Kita buat AppBar semi-transparan
        extendBodyBehindAppBar: true, 
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          title: const Text('Membaca...'),
        ),
        body: BlocBuilder<ReaderCubit, ReaderState>(
          builder: (context, state) {
            
            // --- State Loading ---
            if (state is ReaderLoading || state is ReaderInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // --- State Error ---
            if (state is ReaderError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            // --- State Sukses (Loaded) ---
            if (state is ReaderLoaded) {
              // Ini adalah inti dari pembaca manga
              return ListView.builder(
                padding: EdgeInsets.zero, // Hapus padding atas
                itemCount: state.pageUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = state.pageUrls[index];

                  // Tampilkan setiap halaman sebagai gambar
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.fitWidth, // Buat gambar memenuhi lebar layar
                    
                    // Tampilkan loading indicator per gambar
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        heightFactor: 5, // Beri sedikit ruang
                        child: CircularProgressIndicator(),
                      );
                    },

                    // Tampilkan error jika 1 gambar gagal dimuat
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, color: Colors.red),
                      );
                    },
                  );
                },
              );
            }

            return const Center(child: Text('State tidak dikenal'));
          },
        ),
      ),
    );
  }
}