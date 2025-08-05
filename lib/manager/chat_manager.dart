import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart';

class ChatManager extends ChangeNotifier {
  final AIService _aiService = AIService();
  List<ChatSession> sessions = [];
  ChatSession? currentSession;

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('chat_history');
    if (data != null) {
      final list = jsonDecode(data) as List;
      sessions = list.map((e) => ChatSession.fromMap(e)).toList();
    }
    notifyListeners();
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(sessions.map((e) => e.toMap()).toList());
    await prefs.setString('chat_history', data);
  }

  void startNewChat() {
    currentSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messages: [],
    );
    notifyListeners();
  }

  void openChat(ChatSession session) {
    currentSession = session;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (currentSession == null) return;

    currentSession!.messages.add(ChatMessage(
      sender: "user",
      text: text,
      time: DateTime.now(),
    ));
    notifyListeners();

    final reply = await _aiService.sendMessage(text);

    currentSession!.messages.add(ChatMessage(
      sender: "ai",
      text: reply,
      time: DateTime.now(),
    ));

    if (!sessions.contains(currentSession)) {
      sessions.insert(0, currentSession!);
    }
    await saveHistory();
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    sessions.removeWhere((s) => s.id == id);
    await saveHistory();
    notifyListeners();
  }
}
