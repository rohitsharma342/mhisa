import 'user.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });
}

class Chat {
  final String id;
  final User otherUser;
  final List<ChatMessage> messages;
  final DateTime lastMessageTime;
  final String lastMessage;
  final int unreadCount;
  final bool isTyping;
  
  Chat({
    required this.id,
    required this.otherUser,
    required this.messages,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.unreadCount,
    this.isTyping = false,
  });
}

enum MessageType {
  text,
  audio,
  system,
}