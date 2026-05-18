class RefreshTokenException implements Exception {
  final String message;
  final Object originalException;

  RefreshTokenException({
    required this.originalException,
    this.message = 'Auto refresh token failed',
  });

  @override
  String toString() {
    return message;
  }
}
