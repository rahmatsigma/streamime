import 'dart:async'; // Untuk StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_read/features/auth/logic/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription<User?> _userSubscription;

  AuthCubit() : super(const AuthState()) {
    // Panggil init untuk mulai mendengarkan
    init();
  }

  // Mulai mendengarkan perubahan status login (login, logout, dll)
  void init() {
    _userSubscription = _auth.authStateChanges().listen(_onUserChanged);
  }

  // Fungsi ini dipanggil setiap kali Firebase mendeteksi login/logout
  void _onUserChanged(User? user) {
    if (user != null) {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated, user: null));
    }
  }

  // Fungsi untuk logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Jangan lupa tutup subscription saat Cubit ditutup
  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}