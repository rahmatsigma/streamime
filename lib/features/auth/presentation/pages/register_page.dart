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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Buat akun baru untuk menyimpan manga favorit dan history bacaanmu.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  final emailRegex =
                      RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  if (value != _passwordController.text) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- TAMPILKAN ERROR JIKA ADA ---
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              // --- AKHIR ERROR ---

              ElevatedButton(
                // Panggil fungsi Firebase yang baru
                onPressed: _isProcessing ? null : _registerWithFirebase,
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Daftar Sekarang'),
              ),
              TextButton(
                onPressed: _isProcessing ? null : _cancel,
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}