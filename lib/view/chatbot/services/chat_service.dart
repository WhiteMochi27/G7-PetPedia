import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String apiUrl = dotenv.env['API_URL'] ?? '';
  
  Future<String> getBotResponse(List<ChatMessage> messageHistory) async {
  if (apiKey.isEmpty || apiUrl.isEmpty) {
    return "API configuration error. Please check your environment variables.";
  }

  try {
    // Format message history for the API
    final List<Map<String, dynamic>> contents = [];
    
    // Add conversation history
    for (var i = 0; i < messageHistory.length; i++) {
      var message = messageHistory[i];
      contents.add({
        "role": message.isUser ? "user" : "model",
        "parts": [{"text": message.text}]
      });
    }

    // Prepend bot instructions to the first bot message if needed
    if (!messageHistory[0].isUser) {
      // For the first bot message, we can include instructions in the message itself
      String botInstructions = "I am BarkBot, a friendly and knowledgeable pet care assistant. ";
      contents[0]["parts"][0]["text"] = botInstructions + contents[0]["parts"][0]["text"];
    }

    final response = await http.post(
      Uri.parse('$apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": contents,
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 800,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ?? 
             "I'm sorry, I couldn't generate a response.";
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      return "Sorry, I'm having trouble connecting to my services right now. Please try again later.";
    }
  } catch (e) {
    print('Exception: $e');
    return "I apologize, but there was an error processing your request.";
  }
}
}