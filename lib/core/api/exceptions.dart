// Base class untuk semua exception API
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

// Exception turunan
class ServerException extends ApiException {
  ServerException(String message) : super('Server Error: $message');
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super('Not Found: $message');
}