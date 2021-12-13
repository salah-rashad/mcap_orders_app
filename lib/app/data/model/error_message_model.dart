enum ErrorMessageType {
  error,
  warning,
  info,
}

class ErrorMessage {
  final String title, message;
  final ErrorMessageType type;

  ErrorMessage({
    required this.title,
    required this.message,
    required this.type,
  });
}
