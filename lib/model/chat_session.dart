import '../screen.dart';

class ChatSession {
  final String id;
  final List<ChatMessage> messages;

  ChatSession({required this.id, required this.messages});

  Map<String, dynamic> toMap() => {
        'id': id,
        'messages': messages.map((e) => e.toMap()).toList(),
      };

  factory ChatSession.fromMap(Map<String, dynamic> map) => ChatSession(
        id: map['id'],
        messages: (map['messages'] as List)
            .map((e) => ChatMessage.fromMap(e))
            .toList(),
      );
}
