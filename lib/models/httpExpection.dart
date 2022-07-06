class HttpException implements Exception {
  final String errorMessage;

  const HttpException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}
