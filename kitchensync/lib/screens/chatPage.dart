// ignore_for_file: prefer_const_constructors, unused_field, file_names, library_private_types_in_public_api, prefer_final_fields, unused_element, avoid_print

import 'package:flutter/material.dart';
import 'package:kitchensync/backend/const.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:http/http.dart' as http;
import 'package:kitchensync/styles/size_config.dart';
import 'dart:convert';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingAnimationController;
  late Animation<double> _cursorAnimation;
  String _typingMessage = "";
  Timer? _typingTimer;
  bool _isBotTyping = false;
  bool isTyping = false;
  bool _isTypingInProgress = false;
  final String chatGPTAPIUrl = 'https://api.openai.com/v1/chat/completions';

  void _simulateTyping(String message) {
    int index = 0;
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (index < message.length) {
        _typingMessage += message[index];
        index++;
        if (index == message.length) {
          _typingTimer?.cancel();
          _isBotTyping = false;
          _typingMessage = message;
        }
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cursorAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_typingAnimationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _typingAnimationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _typingAnimationController.forward();
            }
          });
    _typingAnimationController.forward();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    setState(() {
      messages.add(
          {"sender": "bot", "content": "Welcome! How can I assist you today?"});
    });
  }

  Future<void> _sendMessageToChatGPT(String userMessage) async {
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
          'Authorization': 'Bearer ${ApiKeys.LapiKey}',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String botReply =
            responseData['choices'][0]['message']['content'];

        setState(() {
          _isBotTyping = true;
        });
        _simulateBotTyping(botReply);
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
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildChatBubble(String message, bool isUser) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary : AppColors.grey1,
            borderRadius: isUser
                ? BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
          ),
          child: Text(
            message,
            style: isUser ? AppFonts.cardTitle : AppFonts.numbers1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initSizeConfig(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(propHeight(120)),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: propHeight(28),
                ),
                Text(
                  'KitchenGPT',
                  style: AppFonts.appname,
                  textAlign: TextAlign.center,
                ),
              ]),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: propHeight(10)),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                if (index == messages.length && _isTypingInProgress) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "$_typingMessage|",
                        style: TextStyle(),
                      ),
                    ),
                  );
                }
                final message = messages[index];
                final isUser = message["sender"] == "user";
                return _buildChatBubble(message["content"], isUser);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20)
                .copyWith(bottom: propHeight(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                  icon: CircleAvatar(
                    radius: propWidth(40),
                    backgroundColor: _controller.text.trim().isNotEmpty
                        ? AppColors.primary
                        : AppColors.greySub,
                    child: Icon(
                      size: propHeight(20),
                      Icons.send_rounded,
                      color: AppColors.light,
                    ),
                  ),
                  onPressed: () {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      _addMessage(message, 'user');
                      _sendMessageToChatGPT(message);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: propHeight(100)),
        ],
      ),
    );
  }

  void _simulateBotTyping(String message) {
    int index = 0;
    _typingMessage = "";
    bool showCursor = true;

    setState(() {
      _isBotTyping = true;
    });

    _typingTimer?.cancel();
    Timer? cursorTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        showCursor = !showCursor;
      });
    });

    _typingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (index < message.length) {
        setState(() {
          _typingMessage =
              message.substring(0, index + 1) + (showCursor ? "|" : "");
          if (messages.isNotEmpty && messages.last["sender"] == "bot") {
            messages.last["content"] = _typingMessage;
          } else {
            messages.add({"sender": "bot", "content": _typingMessage});
          }
        });
        index++;
      } else {
        timer.cancel();
        cursorTimer.cancel();
        setState(() {
          _typingMessage = message;
          _isBotTyping = false;
          if (messages.isNotEmpty && messages.last["sender"] == "bot") {
            messages.last["content"] = _typingMessage;
          }
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        width: 2.0,
        height: 20.0,
        color: AppColors.greySub,
      ),
    );
  }
}
