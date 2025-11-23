import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- IMPORT FIREBASE
import 'package:go_router/go_router.dart'; // <-- IMPORT GO_ROUTER

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isProcessing = false;
  String? _errorMessage; // Untuk menampilkan error

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- INI FUNGSI BARU YANG TERHUBUNG KE FIREBASE ---
  Future<void> _registerWithFirebase() async {
    // 1. Validasi form
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 2. Mulai loading
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // 3. Panggil Firebase untuk membuat akun
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // (Opsional) Update nama profil pengguna
      // Ini tidak wajib untuk login, tapi bagus untuk 'profile'
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(_nameController.text.trim());
      }

      // 4. Jika berhasil, kembali ke Halaman Utama
      // Firebase otomatis login setelah register
      if (mounted) {
        context.go('/'); // Langsung ke HomePage
      }
    } on FirebaseAuthException catch (e) {
      // 5. Jika Gagal, tampilkan pesan error
      setState(() {
        _errorMessage = e.message ?? "Gagal mendaftar.";
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Terjadi error yang tidak diketahui.";
        _isProcessing = false;
      });
    }
  }
  // --- AKHIR FUNGSI BARU ---

  void _cancel() {
    // Gunakan GoRouter untuk kembali
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                colorScheme.primary.withOpacity(0.08),
                BlendMode.srcATop,
              ),
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.75),
                    colorScheme.surface.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          Hero(
                            tag: 'logo',
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/logo.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Buat akun MangaRead',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Buat akun baru untuk menyimpan manga favorit dan history bacaanmu.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.8),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          Form(
                            key: _formKey,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface.withOpacity(
                                      0.78,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.18),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 30,
                                        offset: const Offset(0, 18),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(22),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          'Nama Lengkap',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _nameController,
                                          decoration: InputDecoration(
                                            hintText: 'Nama lengkapmu',
                                            filled: true,
                                            fillColor: colorScheme
                                                .surfaceVariant
                                                .withOpacity(0.6),
                                            prefixIcon: const Icon(
                                              Icons.badge_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Nama tidak boleh kosong';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Email',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            hintText: 'nama@email.com',
                                            filled: true,
                                            fillColor: colorScheme
                                                .surfaceVariant
                                                .withOpacity(0.6),
                                            prefixIcon: const Icon(
                                              Icons.email_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Email tidak boleh kosong';
                                            }
                                            final emailRegex = RegExp(
                                              r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
                                            );
                                            if (!emailRegex.hasMatch(
                                              value.trim(),
                                            )) {
                                              return 'Format email tidak valid';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Password',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          decoration: InputDecoration(
                                            hintText: 'Minimal 6 karakter',
                                            filled: true,
                                            fillColor: colorScheme
                                                .surfaceVariant
                                                .withOpacity(0.6),
                                            prefixIcon: const Icon(
                                              Icons.lock_outline_rounded,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword =
                                                      !_obscurePassword;
                                                });
                                              },
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Password tidak boleh kosong';
                                            }
                                            if (value.length < 6) {
                                              return 'Password minimal 6 karakter';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Konfirmasi Password',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller:
                                              _confirmPasswordController,
                                          obscureText: _obscureConfirmPassword,
                                          decoration: InputDecoration(
                                            hintText: 'Ulangi passwordmu',
                                            filled: true,
                                            fillColor: colorScheme
                                                .surfaceVariant
                                                .withOpacity(0.6),
                                            prefixIcon: const Icon(
                                              Icons.lock_reset_outlined,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureConfirmPassword
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscureConfirmPassword =
                                                      !_obscureConfirmPassword;
                                                });
                                              },
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Konfirmasi password tidak boleh kosong';
                                            }
                                            if (value !=
                                                _passwordController.text) {
                                              return 'Password tidak sama';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        if (_errorMessage != null)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.08,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.redAccent
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.error_outline,
                                                      color: Colors.redAccent,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        _errorMessage!,
                                                        style: const TextStyle(
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        _isProcessing
                                            ? const SizedBox(
                                                height: 52,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                            : ElevatedButton(
                                                // Panggil fungsi Firebase yang baru
                                                onPressed: _isProcessing
                                                    ? null
                                                    : _registerWithFirebase,
                                                style: ElevatedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                  ),
                                                  backgroundColor: colorScheme
                                                      .primaryContainer,
                                                  foregroundColor: colorScheme
                                                      .onPrimaryContainer,
                                                  elevation: 0,
                                                ),
                                                child: const Text(
                                                  'Daftar Sekarang',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                        const SizedBox(height: 14),
                                        OutlinedButton(
                                          onPressed: _isProcessing
                                              ? null
                                              : _cancel,
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            side: BorderSide(
                                              color: colorScheme.primary
                                                  .withOpacity(0.6),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            foregroundColor:
                                                colorScheme.primary,
                                          ),
                                          child: const Text(
                                            'Batal',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: Material(
                    color: Colors.white.withOpacity(0.14),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _cancel,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
