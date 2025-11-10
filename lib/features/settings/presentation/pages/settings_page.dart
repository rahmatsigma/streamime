import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/features/theme/logic/theme_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = context.watch<ThemeCubit>().state.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Tema Gelap'),
            subtitle: const Text('Aktifkan atau matikan mode gelap'),

            value: isDarkMode,

            onChanged: (value) {
              context.read<ThemeCubit>().toggleTheme(value);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Notifikasi'),
            subtitle: const Text('Dapatkan update bab terbaru'),
            value: _notificationEnabled,
            onChanged: (value) {
              // Biarkan setState ini untuk switch notifikasi
              setState(() {
                _notificationEnabled = value;
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Ganti Password'),
            subtitle: const Text('Perbarui password akun kamu'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu ganti password akan segera hadir.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}