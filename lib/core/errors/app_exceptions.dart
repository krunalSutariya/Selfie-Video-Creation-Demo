abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => 'AppException: $message (Status code: $statusCode)';
}

class ServerException extends AppException {
  ServerException(String message, [int? statusCode]) : super(message, statusCode);
}

class CacheException extends AppException {
  CacheException(String message) : super(message);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class AuthException extends AppException {
  AuthException(String message, [int? statusCode]) : super(message, statusCode);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}

class FileException extends AppException {
  FileException(String message) : super(message);
}

