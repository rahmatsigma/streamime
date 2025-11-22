import 'package:flutter/material.dart';
// import 'package:manga_read/core/image_proxy.dart'; // HAPUS INI JANGAN DIPAKAI DISINI

class MangaGridCard extends StatelessWidget {
  final String title;
  final String coverUrl;

  const MangaGridCard({
    super.key,
    required this.title,
    required this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan Container dengan BoxShadow agar terlihat premium
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // ClipRRect untuk memotong gambar sesuai sudut lengkung
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. GAMBAR (Background)
            Image.network(
              coverUrl, // URL INI SUDAH DI-PROXY DARI REPOSITORY. JANGAN DIPROXY LAGI.
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey[900],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                );
              },
            ),

            // 2. GRADIENT (Bayangan Hitam di Bawah)
            // Agar tulisan putih terbaca jelas di atas gambar apapun
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80, // Tinggi area bayangan
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9), // Hitam pekat di bawah
                    ],
                  ),
                ),
              ),
            ),

            // 3. JUDUL (Text)
            Positioned(
              bottom: 10,
              left: 8,
              right: 8,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  // Tambahan shadow teks biar makin jelas
                  shadows: [
                    Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}