import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import user

// Status otentikasi
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user; // Data pengguna dari Firebase

  const AuthState({this.status = AuthStatus.unknown, this.user});

  // Helper copyWith
  AuthState copyWith({AuthStatus? status, User? user}) {
    return AuthState(status: status ?? this.status, user: user ?? this.user);
  }

  @override
  List<Object?> get props => [status, user];
}
