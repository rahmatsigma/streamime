import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({
    super.key,
    this.isLoggedIn = false,
    this.favoriteManga = const <String>[],
  });

  final bool isLoggedIn;
  final List<String> favoriteManga;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Favorit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // --- PERUBAHAN LOGIKA DI SINI ---
        child: isLoggedIn ? _buildFavoriteList() : _buildLoginPrompt(context),
      ),
    );
  }

  // --- WIDGET BARU ---
  // (Memindahkan logic list view ke sini)
  Widget _buildFavoriteList() {
    if (favoriteManga.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada manga favorit yang tersimpan.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: favoriteManga.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final title = favoriteManga[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white12,
            child: Text(
              title.isNotEmpty
                  ? title.substring(0, 1).toUpperCase()
                  : '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(title),
          subtitle: const Text('Lihat detail manga ini'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Buka detail "$title"')),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Masuk terlebih dahulu untuk melihat manga favoritmu.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Silakan kembali ke Home dan login melalui menu profil.'),
                ),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}