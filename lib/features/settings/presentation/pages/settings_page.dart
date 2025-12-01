import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_read/features/auth/logic/auth_cubit.dart';
import 'package:manga_read/features/theme/logic/theme_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

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
    _nameController = TextEditingController(
      text: _currentUser?.displayName ?? '',
    );

    _nameController.addListener(() {
      setState(() {
        _isEditingName =
            _nameController.text != (_currentUser?.displayName ?? '');
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- FUNGSI CEK PERMISSION (UPDATE: Support Kamera & Galeri) ---
  Future<bool> _checkPermission(ImageSource source) async {
    if (kIsWeb) return true; // Web selalu aman

    PermissionStatus status;

    if (source == ImageSource.camera) {
      // 1. Cek Izin Kamera
      status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }
    } else {
      // 2. Cek Izin Galeri (Photos/Storage)
      status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          status = await Permission.storage.request();
        }
      }
    }

    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      if (mounted) _showOpenSettingsDialog();
      return false;
    }

    return false;
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Izin Diperlukan"),
        content: const Text(
          "Aplikasi butuh akses kamera/galeri. Silakan buka pengaturan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text("Buka Pengaturan"),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI PILIH SUMBER GAMBAR (Pop-up Bawah) ---
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Ambil dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSaveImageToFirestore(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSaveImageToFirestore(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- FUNGSI UPDATE FOTO (UPDATE: Terima Parameter Source) ---
  Future<void> _pickAndSaveImageToFirestore(ImageSource source) async {
    // 1. Cek Izin sesuai Source (Kamera/Galeri)
    if (!kIsWeb) {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        bool hasPermission = await _checkPermission(source);
        if (!hasPermission) return;
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source, // Pakai source yang dipilih user
        imageQuality: 20,
        maxWidth: 500,
      );

      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final String uid = _currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'avatarBase64': base64Image,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isUploadingImage = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal simpan foto: $e')));
      }
    }
  }

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal update profil: $e')));
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
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setDialogState(() => obscureNew = !obscureNew),
                        ),
                      ),
                      validator: (v) => (v != null && v.length < 6)
                          ? 'Minimal 6 karakter'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPassController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Ulangi Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setDialogState(
                            () => obscureConfirm = !obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (v) => v != newPassController.text
                          ? 'Password tidak sama'
                          : null,
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
                        await _currentUser?.updatePassword(
                          newPassController.text,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password berhasil diganti! Silakan login ulang.',
                              ),
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        String err = e.message ?? 'Gagal ganti password';
                        if (e.code == 'requires-recent-login') {
                          err =
                              'Demi keamanan, silakan Logout dan Login ulang sebelum mengganti password.';
                        }
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(err)));
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah kamu yakin ingin keluar dari akun ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().signOut();
              context.go('/login');
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Berhasil logout.')));
            },
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        context.watch<ThemeCubit>().state.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pengaturan')),
        body: const Center(
          child: Text("Silakan login untuk mengakses pengaturan akun."),
        ),
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
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    ImageProvider? imageProvider;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final base64String = data?['avatarBase64'];
                      if (base64String != null && base64String.isNotEmpty) {
                        imageProvider = MemoryImage(base64Decode(base64String));
                      }
                    }
                    if (imageProvider == null &&
                        _currentUser?.photoURL != null) {
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
                              style: TextStyle(
                                fontSize: 40,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    );
                  },
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    // UPDATE: Panggil dialog pilihan, bukan langsung upload
                    onTap: _isUploadingImage ? null : _showImageSourceDialog,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: _isUploadingImage
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Informasi Akun",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: _currentUser?.email,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),
          ),
          const SizedBox(height: 24),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_reset, color: Colors.orange),
            ),
            title: const Text('Ganti Password'),
            subtitle: const Text('Ubah kata sandi akun kamu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context),
          ),

          const Divider(height: 32),

          const Text(
            "Aplikasi",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.purple,
              ),
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
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.green,
              ),
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
                _showLogoutDialog();
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "Keluar Akun",
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Versi Aplikasi 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
