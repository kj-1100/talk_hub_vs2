// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/meus_preencha.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';

class ChatBotPage extends StatefulWidget {
  final String userId;

  const ChatBotPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  late List<Map<String, dynamic>> messages = [];
  late DialogFlowtter dialogFlowtter;
  late final String solicitacao;
  TemaDoApp tema = TemaDoApp();
  late final String message;
  late final String userId;
  DateTime? _ultimoEnvio;

  @override
  void initState() {
    super.initState();
    tema = Provider.of<TemaDoApp>(context, listen: false);
    userId = widget.userId;
    dialogFlowtter = DialogFlowtter();
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) {
      print('A mensagem está vazia');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A mensagem está vazia'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      DetectIntentResponse response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(text: TextInput(text: text)),
      );
      if (response.message == null) return;
      // Adicione a mensagem ao Firestore
      await FirebaseFirestore.instance
          .collection("Usuario")
          .doc(userId)
          .collection('messagems')
          .add({
        'userMessage': text,
        'botMessage': response.message?.text?.text?.first ?? '',
        'timestamp': DateTime.now(),
      });
    }
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Usuario")
          .doc(userId)
          .collection('messagems')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text("Carregando...");
        final messagems = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: messagems.length,
          itemBuilder: (context, index) {
            final message = messagems[index].get('botMessage');
            final userMessage = messagems[index].get('userMessage');
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: tema.mensagemUserColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              userMessage,
                              style: TextStyle(color: tema.pretoEBrancoColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              "$message ${verificandoRespostaBot(message)}",
                              style: TextStyle(color: tema.pretoEBrancoColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String verificandoRespostaBot(String message) {
    String solicitacao = "";
    switch (message) {
      case "este é seu id de usuário":
        solicitacao = userId;
        break;
      default:
    }
    return solicitacao;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fala-Suporte',
          style: TextStyle(
            color: tema.pretoEBrancoColor,
          ),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: tema.cabecarioColor,
      ),
      backgroundColor: tema.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          digitaEnviaMensagem(),
        ],
      ),
    );
  }

  Widget digitaEnviaMensagem() {
    return Container(
      decoration: BoxDecoration(
        color: tema.cabecarioColor,
        borderRadius:
            BorderRadius.circular(8.0), 
      ),
      child: Row(
        children: [
          Expanded(
            child: Preencha(
              controller: _messageController,
              hintText: "Digite sua mensagem",
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: () {
              final agora = DateTime.now();
              if (_ultimoEnvio == null ||
                  agora.difference(_ultimoEnvio!) >=
                      const Duration(milliseconds: 4000)) {
                final message = _messageController.text;
                sendMessage(message);
                _messageController.clear();
                _ultimoEnvio = agora;
              } else {
                print(
                    "Aguarde pelo menos 3 segundos antes de enviar outra mensagem.");
              }
            },
            icon: const Icon(
              Icons.send_outlined,
              color: Colors.blueAccent,
              size: 45,
            ),
          ),
        ],
      ),
    );
  }
}
