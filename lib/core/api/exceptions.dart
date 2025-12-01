// File: lib/core/api/exceptions.dart

// 1. INDUK (Parent)
class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}

// 2. ANAK (Child) - Perhatikan 'extends Failure'
class ServerException extends Failure {
  ServerException(String message) : super(message);
}

class NotFoundException extends Failure {
  NotFoundException(String message) : super(message);
}

// Tambahan jika ada error koneksi
class ConnectionFailure extends Failure {
  ConnectionFailure(String message) : super(message);
}
