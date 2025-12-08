// Application-specific exceptions
class ServerException implements Exception {
  final String message;
  ServerException([this.message = '']);
}
