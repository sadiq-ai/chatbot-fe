enum MessageType { audio, image, text, video }

class ChatModel {
  ChatModel({
    required this.author,
    required this.message,
    required this.timestamp,
    required this.type,
  });
  final String author;
  final String message;
  final DateTime timestamp;
  final MessageType type;
}
