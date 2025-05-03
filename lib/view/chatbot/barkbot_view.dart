import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:petpedia/view/chatbot/providers/chat_provider.dart';
import 'package:petpedia/view/chatbot/models/chat_message.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';

class BarkBotView extends StatefulWidget {
  const BarkBotView({super.key});

  @override
  State<BarkBotView> createState() => _BarkBotViewState();
}

class _BarkBotViewState extends State<BarkBotView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<ChatProvider>(context, listen: false).clearMessages();
      
      Provider.of<ChatProvider>(context, listen: false)
          .addBotMessage("Hi there! I'm BarkBot, your pet care assistant. How can I help you today?");
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildQuickActions() {
    final quickActions = [
      'Vaccination Schedule',
      'Feeding Tips',
      'Walking Routine',
      'Grooming Advice',
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: quickActions
              .map((action) => Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        Provider.of<ChatProvider>(context, listen: false)
                            .sendMessage(action);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          action,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontFamily: 'ComicNeue',
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Remove default app bar
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Header
            PageTitle(
              icon: 'assets/images/icon_barkbot.png',
              title: 'Barkbot',
              subtitle: 'AI Chatbot Assistant',
            ),

            Positioned.fill(
              top: 100,
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  _scrollToBottom();
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < chatProvider.messages.length) {
                              return _buildMessageItem(chatProvider.messages[index]);
                            } else {
                              return _buildTypingIndicator();
                            }
                          },
                        ),
                      ),

                      _buildQuickActions(),
                      _buildMessageInput(),
                    ],
                  );
                },
              ),
            ),

            // Home button at bottom
            const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final timeString = DateFormat('h:mm a').format(message.timestamp);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) 
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Image.asset(
                  'assets/images/icon_barkbot.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.blue
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontFamily: 'ComicNeue',
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.isUser ? 'You' : 'BarkBot',
                        style: TextStyle(
                          color: message.isUser 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black54,
                          fontSize: 12,
                          fontFamily: message.isUser ? 'ComicNeue' : 'Baloo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' • $timeString',
                        style: TextStyle(
                          color: message.isUser 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black54,
                          fontSize: 12,
                          fontFamily: 'ComicNeue',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.blue[800],
                radius: 16,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 16,
            child: Image.asset(
              'assets/images/icon_barkbot.png',
              width: 20,
              height: 20,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _buildDot(delay: 0),
                _buildDot(delay: 300),
                _buildDot(delay: 600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required int delay}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: (value < 0.5) ? 2 * value : 2 * (1 - value),
            child: child,
          );
        },
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
  return Padding(
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      bottom: 70,
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontFamily: 'ComicNeue',
              ),
              decoration: InputDecoration(
                hintText: 'Ask something about pet care...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'ComicNeue',
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Image.asset(
                'assets/images/meteor-icons_paper-plane.png',
                width: 24,
                height: 24,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    ),
  );
}

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false)
          .sendMessage(_textController.text);
      _textController.clear();
      _focusNode.requestFocus();
    }
  }
}
