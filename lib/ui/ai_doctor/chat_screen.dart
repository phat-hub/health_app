import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();

    // Theo dõi khi user cuộn
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        _isUserScrolling = true;
      }
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        // Đang ở cuối
        _isUserScrolling = false;
      }
    });
  }

  void _scrollToBottom() {
    if (!_isUserScrolling) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 60,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatManager = Provider.of<ChatManager>(context);
    final messages = chatManager.currentSession?.messages ?? [];

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bác sĩ AI"),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.sender == "user";
                final timeString = DateFormat('HH:mm').format(msg.time);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                AssetImage("assets/images/doctor.png"),
                          ),
                        ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF1E88E5)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 0),
                              bottomRight: Radius.circular(isUser ? 0 : 16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeString,
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      isUser ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isUser)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                AssetImage("assets/images/user.png"),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Nhập tin nhắn...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _isSending
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: CircularProgressIndicator(),
                        )
                      : CircleAvatar(
                          backgroundColor: const Color(0xFF1E88E5),
                          child: IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.white, size: 20),
                            onPressed: () async {
                              final text = _controller.text.trim();
                              if (text.isEmpty) return;

                              final message = text;
                              _controller.clear();
                              _scrollToBottom();

                              setState(() => _isSending = true);
                              await chatManager.sendMessage(message);
                              setState(() => _isSending = false);

                              _scrollToBottom();
                            },
                          ),
                        ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
