class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isImage;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isImage = false,
  });
}