//Contributed by [Tok Saw Ping]
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isLoaded = false; // Add a flag for loaded state
  final ChatService _chatService = ChatService();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedMessages = prefs.getStringList('chat_messages') ?? [];
      
      _messages = storedMessages
          .map((str) => ChatMessage.fromJson(jsonDecode(str)))
          .toList();

      _isLoaded = true; // Set flag to true once loading is complete
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
      _isLoaded = true; // Set flag to true to avoid stuck loading state
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (!_isLoaded || text.trim().isEmpty) return; // Ensure data is loaded

    final userMessage = ChatMessage(text: text, isUser: true);
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();
    
    await _saveMessages();

    final response = await _chatService.getBotResponse(_messages);
    
    final botMessage = ChatMessage(text: response, isUser: false);
    _messages.add(botMessage);
    _isLoading = false;
    notifyListeners();
    
    await _saveMessages();
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages
          .map((msg) => jsonEncode(msg.toJson()))
          .toList();

      await prefs.setStringList('chat_messages', messagesJson);
    } catch (e) {
      print('Error saving messages: $e');
    }
  }

  Future<void> clearMessages() async {
    _messages.clear();
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_messages');
    } catch (e) {
      print('Error clearing saved messages: $e');
    }
  }

  void addBotMessage(String message) {
    final botMessage = ChatMessage(
      text: message,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    _messages.add(botMessage);
    notifyListeners();
    _saveMessages();
  }
}