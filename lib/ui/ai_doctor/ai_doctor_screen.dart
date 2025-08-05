import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screen.dart';

class AiDoctorScreen extends StatefulWidget {
  const AiDoctorScreen({super.key});

  @override
  State<AiDoctorScreen> createState() => _AiDoctorScreenState();
}

class _AiDoctorScreenState extends State<AiDoctorScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ChatManager>(context, listen: false).loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final chatManager = Provider.of<ChatManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bác sĩ AI"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Bạn có câu hỏi nào cho bác?",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    chatManager.startNewChat();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                  ),
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text(
                    "Hỏi câu hỏi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: chatManager.sessions.isEmpty
                ? const Center(child: Text("Chưa có lịch sử trò chuyện"))
                : ListView.builder(
                    itemCount: chatManager.sessions.length,
                    itemBuilder: (context, index) {
                      final session = chatManager.sessions[index];
                      final lastMsg = session.messages.isNotEmpty
                          ? session.messages.last.text
                          : "";
                      final time = session.messages.isNotEmpty
                          ? session.messages.last.time
                          : DateTime.now();
                      return Dismissible(
                        key: Key(session.id),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          chatManager.deleteSession(session.id);
                        },
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF1E88E5),
                            child:
                                Icon(Icons.local_hospital, color: Colors.white),
                          ),
                          title: Text(
                            lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(time.toString()),
                          onTap: () {
                            chatManager.openChat(session);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ChatScreen()),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
