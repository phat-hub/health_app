import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final chatManager = Provider.of<ChatManager>(context);
    final messages = chatManager.currentSession?.messages ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trò chuyện"),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.sender == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF1E88E5)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: "Đặt một câu hỏi..."),
                  ),
                ),
                _isSending
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CircularProgressIndicator(),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF1E88E5)),
                        onPressed: () async {
                          final text = _controller.text.trim();
                          if (text.isEmpty) return;
                          setState(() => _isSending = true);
                          await chatManager.sendMessage(text);
                          setState(() => _isSending = false);
                          _controller.clear();
                        },
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
