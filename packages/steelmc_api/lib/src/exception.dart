class SteelMcApiException implements Exception {
  const SteelMcApiException(
    this.message, {
    this.statusCode,
    this.cancelled = false,
  });

  final String message;
  final int? statusCode;

  /// True when the request was cancelled via a `CancelToken`.
  final bool cancelled;

  @override
  String toString() => message;
}
