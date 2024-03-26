// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, file_names, avoid_unnecessary_containers, sized_box_for_whitespace

import 'dart:convert';
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
    final String itemsString =
        await rootBundle.loadString('assets/data/items.json');
    final Map<String, dynamic> itemsJson = json.decode(itemsString);
    setState(() {
      itemsList = (itemsJson['items'] as List)
          .map((itemJson) => Item.fromJson(itemJson))
          .toList();
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
    // Initialize index to track the current character position
    int index = 0;
    _isBotTyping = true;

    // Cancel any previous timer to avoid overlapping effects
    _typingTimer?.cancel();

    // Start a new timer that periodically updates the typing message
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Check if all characters have been "typed"
      if (index < message.length) {
        setState(() {
          // Append the next character to the typing message
          _typingMessage = message.substring(0, index + 1);
          // Update the last message or add a new one if necessary
          if (messages.isNotEmpty &&
              messages.last["sender"] == "bot" &&
              _isBotTyping) {
            messages.last["data"] = _typingMessage;
          } else {
            messages.add({"sender": "bot", "data": _typingMessage});
          }
        });
        index++;
      } else {
        // Stop the timer and reset typing state once the entire message is "typed"
        timer.cancel();
        setState(() {
          _isBotTyping = false;
          _typingMessage = ""; // Clear the temporary typing message
        });
      }

      // Scroll to the bottom to ensure the latest part of the message is visible
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleUserInput(String input) {
    setState(() {
      messages.add({"sender": "user", "data": input});
    });

    // Simulate a bot response based on the user input
    if (responses.containsKey(input)) {
      final String botResponse = responses[input]![
          0]; // Example: picking the first response for simplicity
      _simulateBotTyping(botResponse);
    } else {
      _simulateBotTyping("I'm not sure how to respond to that.");
    }
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["sender"] == "user";
                return _buildChatBubble(message["data"], isUser,
                    _isBotTyping && index == messages.length - 1);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.primary
                : AppColors.grey1, // Assuming you have these colors defined
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
          child: isTyping && !isUser
              ? TypingIndicator()
              : Text(
                  message,
                  style: isUser
                      ? AppFonts.cardTitle
                      : AppFonts
                          .numbers1, // Assuming you have these fonts defined
                ),
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20, // Adjust the height to fit your design
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ...List.generate(3, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              height: 8.0,
              width: 8.0,
              decoration: BoxDecoration(
                color:
                    AppColors.greySub, // Assuming you have this color defined
                shape: BoxShape.circle,
              ),
              // Creating a simple bounce effect
              child: Opacity(
                opacity: (index + 1) / 3,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 2.0,
                    width: 2.0,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
