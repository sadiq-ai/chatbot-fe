import 'product_model.dart';

enum MessageType { audio, image, text, video, product }

class ChatModel {
  ChatModel({
    required this.author,
    required this.message,
    required this.timestamp,
    required this.type,
    this.product,
  });
  final String author;
  final String message;
  final DateTime timestamp;
  final MessageType type;
  final ProductModel? product;
}
