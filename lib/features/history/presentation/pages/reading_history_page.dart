import 'package:flutter/material.dart';

class ReadingHistoryPage extends StatelessWidget {
  const ReadingHistoryPage({
    super.key,
    this.isLoggedIn = false,
    this.historyItems = const <String>[],
  });

  final bool isLoggedIn;
  final List<String> historyItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Baca'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoggedIn ? _buildHistoryList() : _buildLoginPrompt(context),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (historyItems.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada history bacaan. Mulai baca manga favoritmu sekarang!',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: historyItems.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final history = historyItems[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(history),
          subtitle: const Text('Ketuk untuk melanjutkan membaca'),
          trailing: const Icon(Icons.play_arrow),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Melanjutkan "$history"')),
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
            'Masuk terlebih dahulu untuk melihat history bacaanmu.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur login akan segera tersedia.'),
                ),
              );
            },
            child: const Text('Login Sekarang'),
          ),
        ],
      ),
    );
  }
}
