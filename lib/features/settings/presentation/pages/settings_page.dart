import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/theme/logic/theme_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  
  bool _notificationEnabled = true;
  bool _isEditingName = false; 
  bool _isUploadingImage = false; 
  User? _currentUser;

  final ImagePicker _picker = ImagePicker(); 

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: _currentUser?.displayName ?? '');
    
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

  // --- FUNGSI UPDATE FOTO (VERSI WEB FRIENDLY) ---
  Future<void> _pickAndSaveImageToFirestore() async {
    try {
      // 1. Pilih Gambar
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 20, 
        maxWidth: 500,
      );
      
      if (image == null) return; 

      setState(() => _isUploadingImage = true);

      // 2. Konversi Gambar ke Base64 (CARA BARU - AMAN DI WEB)
      // Kita baca bytes langsung dari XFile, jangan bikin File() baru
      final bytes = await image.readAsBytes(); 
      final String base64Image = base64Encode(bytes);

      // 3. Simpan ke Firestore (users/{uid})
      final String uid = _currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'avatarBase64': base64Image, 
      }, SetOptions(merge: true)); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto berhasil disimpan!'), backgroundColor: Colors.green),
        );
        setState(() => _isUploadingImage = false);
      }

    } catch (e) {
      print("Error: $e");
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal simpan foto: $e')),
        );
      }
    }
  }
  // ------------------------------------------------

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;

    try {
      await _currentUser!.updateDisplayName(_nameController.text.trim());
      await _currentUser!.reload(); 
      
      if (mounted) {
        context.read<AuthCubit>().checkAuthStatus(); 
        
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

  void _showChangePasswordDialog(BuildContext context) {
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
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
                        }
                      } on FirebaseAuthException catch (e) {
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
    final bool isDarkMode = context.watch<ThemeCubit>().state.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

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
          Center(
            child: Stack(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).snapshots(),
                  builder: (context, snapshot) {
                    ImageProvider? imageProvider;
                    
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      final base64String = data?['avatarBase64'];
                      
                      if (base64String != null && base64String.isNotEmpty) {
                        imageProvider = MemoryImage(base64Decode(base64String));
                      }
                    }

                    if (imageProvider == null && _currentUser?.photoURL != null) {
                      imageProvider = NetworkImage(_currentUser!.photoURL!);
                    }

                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? Text(
                              (_nameController.text.isNotEmpty) 
                                  ? _nameController.text[0].toUpperCase() 
                                  : 'U',
                              style: TextStyle(fontSize: 40, color: theme.colorScheme.onPrimaryContainer),
                            )
                          : null,
                    );
                  }
                ),
                
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingImage ? null : _pickAndSaveImageToFirestore,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                      ),
                      child: _isUploadingImage 
                        ? const SizedBox(
                            width: 18, height: 18, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text("Informasi Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),

          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: _currentUser?.email,
            readOnly: true, 
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),
          ),
          const SizedBox(height: 24),

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

          const Text("Aplikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

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