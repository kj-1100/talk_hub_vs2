// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaBotPage extends StatefulWidget {
  const TelaBotPage({super.key});

  @override
  TelaBotPageState createState() => TelaBotPageState();
}

class TelaBotPageState extends State<TelaBotPage> {
  final _messageList = <ChatMessage>[];
  final _controllerText = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controllerText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
      ),
      body: Column(
        children: <Widget>[
          _buildList(),
          const Divider(height: 1.0),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, int index) =>
            ChatMessageListItem(chatMessage: _messageList[index]),
        itemCount: _messageList.length,
      ),
    );
  }

  void _sendMessage({required String text}) {
    _controllerText.clear();
    _addMessage(name: "batata", text: text, type: ChatMessageType.sent);
    _dialogFlowRequest(query: text); // Chama o Dialogflow
  }

  void _addMessage(
      {required String name,
      required String text,
      required ChatMessageType type}) {
    var message = ChatMessage(
      text: text,
      name: name,
      type: type,
    );
    setState(() {
      _messageList.insert(0, message);
    });
  }

  Future<void> _dialogFlowRequest({required String query}) async {
  

    final url = ("https://console.dialogflow.com/api-client/demo/embedded/0de7f59a-3264-4f97-a4af-091b791cb734");
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'queryInput': {
        'text': {
          'text': query,
          'languageCode': 'pt-BR',
        },
      },
    });

    final response = await http.post(url as Uri, headers: headers, body: body);
    final result = jsonDecode(response.body);
    final fulfillmentText = result['queryResult']['fulfillmentText'];

    _addMessage(
        name: 'Professor',
        text: fulfillmentText,
        type: ChatMessageType.received);
  }

  Widget _buildTextField() {
    return Flexible(
      child: TextField(
        controller: _controllerText,
        decoration: const InputDecoration.collapsed(
          hintText: "Enviar mensagem",
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      child: IconButton(
        icon: const Icon(
          Icons.send,
        ),
        onPressed: () {
          if (_controllerText.text.isNotEmpty) {
            _sendMessage(text: _controllerText.text);
          }
        },
      ),
    );
  }

  Widget _buildUserInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          _buildTextField(),
          _buildSendButton(),
        ],
      ),
    );
  }
}

enum ChatMessageType { sent, received }

class ChatMessage {
  final String text;
  final String name;
  final ChatMessageType type;

  ChatMessage({required this.text, required this.name, required this.type});
}

class ChatMessageListItem extends StatelessWidget {
  final ChatMessage chatMessage;

  const ChatMessageListItem({super.key, required this.chatMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: chatMessage.type == ChatMessageType.sent
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: chatMessage.type == ChatMessageType.sent
                ? Colors.blue
                : const Color.fromARGB(255, 33, 43, 54),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            chatMessage.text,
            style: TextStyle(
                color: chatMessage.type == ChatMessageType.sent
                    ? Colors.black87
                    : Colors.white70, // Change this color according to your preference
                )
          ),
        ),
      ),
    );
  }
}
