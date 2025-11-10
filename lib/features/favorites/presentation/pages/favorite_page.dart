import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({
    super.key,
    this.favoriteManga = const <String>[],
  });

  final List<String> favoriteManga;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Favorit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: favoriteManga.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada manga favorit yang tersimpan.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
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
              ),
      ),
    );
  }
}
