// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, file_names, avoid_unnecessary_containers, sized_box_for_whitespace, unused_import

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kitchensync/screens/appBar.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/styles/AppFonts.dart';
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
  bool _isBotTyping = false;
  String _typingMessage = "";
  Timer? _typingTimer; // Make _typingTimer nullable
  List<Item> itemsList = [];
  String? selectedItem;
  Map<String, List<String>> responses = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadItems();
    await _loadResponses();
    _addInitialMessage();
  }

  Future<void> _loadItems() async {
    final String itemsString = await rootBundle.loadString('items.json');
    final List<dynamic> itemsJson = json.decode(itemsString);
    setState(() {
      itemsList = itemsJson.map((itemJson) => Item.fromJson(itemJson)).toList();
    });
  }

  Future<void> _loadResponses() async {
    final String responsesString =
        await rootBundle.loadString('assets/data/responses.json');
    final Map<String, dynamic> responsesJson = json.decode(responsesString);
    setState(() {
      responses = Map.from(responsesJson['responses']).map((key, value) {
        return MapEntry(key, List<String>.from(value));
      });
    });
  }

  void _addInitialMessage() {
    setState(() {
      messages.add({
        "sender": "bot",
        "data": "Welcome! Please select an item to get started."
      });
    });
  }

  void _simulateBotTyping(String message) {
    int index = 0;
    setState(() {
      // Check if the bot is already typing; if not, add a new typing message
      if (!_isBotTyping ||
          messages.isEmpty ||
          messages.last["sender"] != "bot") {
        messages.add({"sender": "bot", "data": ""});
      }
      _isBotTyping = true;
    });

    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (index < message.length) {
        setState(() {
          _typingMessage =
              '${message.substring(0, index + 1)}|'; // Append cursor
          // Ensure we update the last bot message, not add a new one
          messages.last["data"] = _typingMessage; // Update last message
        });
        index++;
      } else {
        // Once complete, remove cursor and cancel timer
        setState(() {
          _typingMessage = message; // Full message without cursor
          messages.last["data"] = _typingMessage; // Update last message
          _isBotTyping = false; // Typing done
        });
        timer.cancel();
        _scrollToBottom(); // Scroll to bottom after typing is done
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleUserInput(String input) {
    // Clear the text field after the message is sent
    _controller.clear();

    // Split the user input into words for case-insensitive matching
    final List<String> inputWords = input.toLowerCase().split(' ');

    setState(() {
      messages.add({"sender": "user", "data": input});
    });

    // Search for a bot response that contains any of the input words
    String botResponse = "I'm not sure how to respond to that.";
    for (String word in inputWords) {
      for (String key in responses.keys) {
        if (key.toLowerCase().contains(word)) {
          botResponse =
              responses[key]![0]; // Get the first response for simplicity
          break;
        }
      }
      if (botResponse != "I'm not sure how to respond to that.") {
        // Found a response, no need to keep looking
        break;
      }
    }

    _simulateBotTyping(botResponse);
  }

  @override
  void dispose() {
    _typingTimer?.cancel(); // Safely cancel the timer if it's been initialized
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
              physics: BouncingScrollPhysics(),
              itemCount: messages.length +
                  (_isBotTyping ? 1 : 0), // Adjust for typing indicator
              itemBuilder: (context, index) {
                if (_isBotTyping && index == messages.length) {
                  // Return TypingIndicator here instead of a chat bubble
                  return Align(
                    alignment: Alignment.centerLeft,
                    child:
                        TypingIndicator(), // Ensure this is styled to match your chat UI
                  );
                }
                final message = messages[index];
                final isUser = message["sender"] == "user";
                return _buildChatBubble(message["data"], isUser, false);
              },
            ),
          ),
          _inputSection(),
        ],
      ),
    );
  }

  Widget _inputSection() {
    // This widget controls the display of the input section based on the state (e.g., item selected or not)
    return selectedItem == null
        ? _itemSelectionDropdown()
        : _messageInputField();
  }

  Widget _itemSelectionDropdown() {
    // Returns a dropdown button for item selection
    return DropdownButtonFormField<String>(
      value: selectedItem,
      onChanged: (newValue) {
        setState(() {
          selectedItem = newValue;
          _handleUserInput(selectedItem!);
        });
      },
      items: itemsList.map<DropdownMenuItem<String>>((Item item) {
        return DropdownMenuItem<String>(
          value: item.itemName,
          child: Text(item.itemName),
        );
      }).toList(),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        filled: true,
        hintText: "Select an item",
      ),
    );
  }

  Widget _messageInputField() {
    // Returns a text field for message input
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        fillColor: Colors.grey[200], // Example color
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
                color: Colors.blue,
                width: 2)), // Example color and border style
        hintText: 'Type your message here...',
        suffixIcon: IconButton(
          icon: Icon(Icons.send),
          onPressed: () => _handleUserInput(_controller.text),
        ),
      ),
      onSubmitted: (value) => _handleUserInput(value),
    );
  }

  Widget _buildChatBubble(String message, bool isUser, bool isTyping) {
    // When isTyping is true and the message sender is not the user, show the typing indicator
    final content = isTyping && !isUser
        ? TypingIndicator()
        : Text(
            message,
            style: isUser ? AppFonts.cardTitle : AppFonts.numbers1,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary : AppColors.grey1,
            borderRadius: isUser
                ? const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
          ),
          child: content,
        ),
      ),
    );
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
        height: 20.0, // Match the height of your TypingIndicator
        color: AppColors.greySub, // Assuming you have this color defined
      ),
    );
  }
}
