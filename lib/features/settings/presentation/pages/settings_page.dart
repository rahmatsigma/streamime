import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/theme/logic/theme_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Controller untuk Nama
  late TextEditingController _nameController;
  
  // Variabel State
  bool _notificationEnabled = true;
  bool _isEditingName = false; // Untuk mendeteksi apakah nama berubah
  User? _currentUser; // User Firebase saat ini

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: _currentUser?.displayName ?? '');
    
    // Listener untuk cek perubahan teks agar tombol Save bisa aktif/tidak (Opsional)
    _nameController.addListener(() {
      setState(() {
        _isEditingName = _nameController.text != (_currentUser?.displayName ?? '');
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- FUNGSI 1: SIMPAN NAMA (Update Profile) ---
  Future<void> _saveProfile() async {
    if (_currentUser == null) return;

    try {
      // Update Display Name di Firebase
      await _currentUser!.updateDisplayName(_nameController.text.trim());
      
      // Reload user data agar update terasa di aplikasi
      await _currentUser!.reload(); 
      
      // Update AuthCubit agar seluruh aplikasi tau nama berubah (misal di Home)
      if (mounted) {
        context.read<AuthCubit>().checkAuthStatus(); // Refresh Cubit
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditingName = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update profil: $e')),
        );
      }
    }
  }

  // --- FUNGSI 2: POP-UP GANTI PASSWORD ---
  void _showChangePasswordDialog(BuildContext context) {
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // StatefulBuilder biar bisa toggle hide/show password di dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ganti Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Masukkan password baru anda.",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Password Baru
                    TextFormField(
                      controller: newPassController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                      ),
                      validator: (v) => (v != null && v.length < 6) ? 'Minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: 16),
                    // Konfirmasi Password
                    TextFormField(
                      controller: confirmPassController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Ulangi Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                      ),
                      validator: (v) => v != newPassController.text ? 'Password tidak sama' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await _currentUser?.updatePassword(newPassController.text);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password berhasil diganti! Silakan login ulang.')),
                          );
                          // Opsional: Logout user setelah ganti password biar aman
                          // context.read<AuthCubit>().signOut();
                          // context.go('/login');
                        }
                      } on FirebaseAuthException catch (e) {
                        // Error umum: requires-recent-login (User harus login ulang dulu)
                        String err = e.message ?? 'Gagal ganti password';
                        if (e.code == 'requires-recent-login') {
                          err = 'Demi keamanan, silakan Logout dan Login ulang sebelum mengganti password.';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil tema untuk styling
    final bool isDarkMode = context.watch<ThemeCubit>().state.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    // Jika user belum login (Guest), tampilkan tampilan terbatas
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pengaturan')),
        body: const Center(child: Text("Silakan login untuk mengakses pengaturan akun.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Pengaturan'),
        actions: [
          // TOMBOL SAVE (Hanya aktif jika ada perubahan nama)
          TextButton(
            onPressed: _isEditingName ? _saveProfile : null,
            child: Text(
              'Simpan',
              style: TextStyle(
                color: _isEditingName ? Colors.blueAccent : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- BAGIAN 1: PROFIL ---
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (_nameController.text.isNotEmpty) 
                        ? _nameController.text[0].toUpperCase() 
                        : 'U',
                    style: TextStyle(fontSize: 40, color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text("Informasi Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),

          // INPUT NAMA (Bisa diedit)
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // INPUT EMAIL (Permanen / ReadOnly)
          TextFormField(
            initialValue: _currentUser?.email,
            readOnly: true, // Gak bisa diedit
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200], // Warna abu biar keliatan disabled
            ),
          ),
          const SizedBox(height: 24),

          // TOMBOL GANTI PASSWORD
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.lock_reset, color: Colors.orange),
            ),
            title: const Text('Ganti Password'),
            subtitle: const Text('Ubah kata sandi akun kamu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context),
          ),
          
          const Divider(height: 32),

          // --- BAGIAN 2: PENGATURAN APLIKASI ---
          const Text("Aplikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          // FITUR TEMA (JANGAN DIUBAH FUNGSINYA)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.purple),
            ),
            title: const Text('Tema Gelap'),
            value: isDarkMode,
            onChanged: (value) {
              context.read<ThemeCubit>().toggleTheme(value);
            },
          ),

          // FITUR NOTIFIKASI
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.notifications_active, color: Colors.green),
            ),
            title: const Text('Notifikasi'),
            value: _notificationEnabled,
            onChanged: (value) {
              setState(() {
                _notificationEnabled = value;
              });
            },
          ),

          const Divider(height: 32),

          // --- BAGIAN 3: ZONA BAHAYA (LOGOUT) ---
          // Saran tambahan: Tombol Logout di sini sangat berguna
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthCubit>().signOut();
                context.go('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Keluar Akun", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Center(child: Text("Versi Aplikasi 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }
}