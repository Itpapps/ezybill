class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Session expired. Please login again.'})
      : super(message: message, statusCode: 401);
}

class NetworkException extends ApiException {
  NetworkException({String message = 'No internet connection'})
      : super(message: message);
}

class ServerException extends ApiException {
  ServerException({String message = 'Server error. Please try again later.'})
      : super(message: message, statusCode: 500);
}
