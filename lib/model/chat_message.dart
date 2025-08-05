class ChatMessage {
  final String sender; // user hoặc ai
  final String text;
  final DateTime time;

  ChatMessage({required this.sender, required this.text, required this.time});

  Map<String, dynamic> toMap() => {
        'sender': sender,
        'text': text,
        'time': time.toIso8601String(),
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        sender: map['sender'],
        text: map['text'],
        time: DateTime.parse(map['time']),
      );
}
