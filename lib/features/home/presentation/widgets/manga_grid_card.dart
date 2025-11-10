import 'package:flutter/material.dart';

class MangaGridCard extends StatelessWidget {
  final String title;
  final String coverUrl;

  const MangaGridCard({
    Key? key,
    required this.title,
    required this.coverUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Penting untuk memotong gambar
      child: Stack(
        fit: StackFit.expand, // Membuat Stack memenuhi kartu
        children: [
          
          // 1. Gambar Cover (Latar Belakang)
          Image.network(
            coverUrl,
            fit: BoxFit.cover,
            
            // (Opsional tapi sangat disarankan) Tampilkan loading
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child; // Gambar selesai dimuat
              return const Center(child: CircularProgressIndicator());
            },

            // (Opsional tapi sangat disarankan) Tampilkan jika error
            errorBuilder: (context, error, stackTrace) {
              // Ini akan menangani jika URL gambar error atau placeholder
              return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
            },
          ),

          // 2. Gradient (agar teks terbaca jelas)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1.0], // Gradient hanya di 50% bagian bawah
              ),
            ),
          ),

          // 3. Judul (di atas Gradient)
          Positioned(
            bottom: 8.0,
            left: 8.0,
            right: 8.0,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                // Beri bayangan agar lebih mudah dibaca
                shadows: [
                  Shadow(blurRadius: 2.0, color: Colors.black),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}