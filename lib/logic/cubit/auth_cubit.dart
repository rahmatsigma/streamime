import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authService) : super(const AuthState()) {
    _subscription = _authService.authStateChanges.listen(_onUserChanged);
  }

  final AuthService _authService;
  StreamSubscription<User?>? _subscription;

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authService.signIn(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.authenticated));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.message ?? 'Gagal masuk, coba lagi.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authService.signUp(name: name, email: email, password: password);
      emit(state.copyWith(status: AuthStatus.authenticated));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.message ?? 'Gagal mendaftar, coba lagi.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _onUserChanged(User? user) {
    if (user == null) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          errorMessage: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
