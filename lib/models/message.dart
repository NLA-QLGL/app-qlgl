enum MessageStatus { sent, delivered, read }

class Message {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });
}
