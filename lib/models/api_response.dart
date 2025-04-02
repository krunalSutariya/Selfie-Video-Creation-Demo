class ApiResponse {
  final bool success;
  final String message;
  final int statusCode;
  final Map<String, dynamic> data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data = const {},
  });
}

