import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(GroqChatApp());
}

class GroqChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groq Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final String _apiKey = "";
  final String _endpoint = "https://api.groq.com/openai/v1/chat/completions";

  Future<void> _sendMessage(String content) async {
    setState(() {
      _isLoading = true;
      _messages.add({"role": "user", "content": content});
    });

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: json.encode({
          "model": "llama-3.3-70b-versatile",
          "messages": _messages,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final reply = responseData['choices'][0]['message']['content'];

        setState(() {
          _messages.add({"role": "assistant", "content": reply});
        });
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Failed to fetch data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Groq Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  alignment: message['role'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message['role'] == 'user'
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['content']!,
                      style: TextStyle(
                          color: message['role'] == 'user'
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Enter your message"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
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
