// ignore_for_file: prefer_const_constructors, prefer_const_declarations, avoid_print

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kitchensync/backend/const.dart';
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Add your ChatGPT API URL here
  final String chatGPTAPIUrl = 'https://api.openai.com/v1/chat/completions';

  @override
  void initState() {
    super.initState();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    setState(() {
      messages.add(
          {"sender": "bot", "content": "Welcome! How can I assist you today?"});
    });
  }

  Future<void> _sendMessageToChatGPT(String userMessage) async {
    // Append the user message to the messages array
    final List<Map<String, dynamic>> messages = [
      {
        "role": "system",
        "content":
            "GPT, as a cutting-edge AI language model, serves as a virtual culinary assistant, providing users with personalized recipe recommendations, culinary advice, and support in the kitchen"
      },
      {
        "role": "user",
        "content": userMessage,
      },
    ];

    final Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": messages,
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.apiKey}',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String botReply =
            responseData['choices'][0]['message']['content'];
        _addMessage(userMessage, 'user');
        _addMessage(botReply, 'bot');
      } else {
        print('API call failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        _addMessage(
            "Sorry, I can't process your message at the moment.", 'bot');
      }
    } catch (e) {
      print('Error sending message to ChatGPT: $e');

      _addMessage(
          "I'm having trouble with the connection. Please try again later.",
          'bot');
    }
  }

  void _addMessage(String message, String sender) {
    setState(() {
      messages.add({"sender": sender, "content": message});
    });
    // Ensure the list scrolls to the new message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["sender"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message["content"],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _sendMessageToChatGPT(value.trim());
                        _controller.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blueAccent,
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _sendMessageToChatGPT(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
