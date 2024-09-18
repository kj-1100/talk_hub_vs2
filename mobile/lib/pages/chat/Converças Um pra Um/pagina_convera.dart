// ignore_for_file: unused_field

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/meus_preencha.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/chat/Conver%C3%A7as%20Um%20pra%20Um/chat_service.dart';
import 'package:talk_hub_vs2/pages/chat/exibir_imagem.dart';

class PaginaConvera extends StatefulWidget {
  final String resiveruserEmail;
  final String resiverUserID;
  final String resiverApelido;

  const PaginaConvera({
    Key? key,
    required this.resiveruserEmail,
    required this.resiverUserID,
    required this.resiverApelido,
  }) : super(key: key);

  @override
  State<PaginaConvera> createState() => _PaginaConveraState();
}

class _PaginaConveraState extends State<PaginaConvera> {
  late TemaDoApp tema;
  final TextEditingController _messageController = TextEditingController();
  // final GrupeChatService _chatServiceGrupe = GrupeChatService();
  final ScrollController _scrollController = ScrollController();
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ChatService _chatService = ChatService();
  List<DocumentSnapshot> convites = [];
  final bool _imagemEnviada = false;
  bool videoOuFoto = false;
  // String? _lastImageUrl;
  int opcoes = 0;

  @override
  void initState() {
    super.initState();
    tema = Provider.of<TemaDoApp>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tema.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.resiverApelido,
          style: TextStyle(color: tema.pretoEBrancoColor),
        ),
        backgroundColor: tema.cabecarioColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
        widget.resiverUserID,
        _chatService.getCurrentUser()?.uid ?? '',
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Erro: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Carregando...");
        }

        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          },
        );

        return ListView(
          controller: _scrollController,
          reverse: false,
          children: snapshot.data!.docs
              .map<Widget>((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data == null) {
      return Container();
    }

    String senderEmail = data["senderEmail"] ?? "Usuário desconhecido";
    String message = data["message"] ?? "Mensagem vazia";
    String? imageUrl = data["imageUrl"];
    String isVideo = data["isVideo"];

    bool isCurrentUser = data["senderId"] == _chatService.getCurrentUser()?.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      padding: const EdgeInsets.all(5),
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (imageUrl != null &&
              isVideo == "foto") // Verifica se não é um vídeo
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExibirImagemPage(
                      imageUrl: imageUrl,
                      isVideo: isVideo,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? tema.mensagemUserColor
                          : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border(
                        top: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 33.0,
                        ),
                        bottom: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 5.0,
                        ),
                        right: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 5.0,
                        ),
                        left: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 5.0,
                        ),
                      ),
                    ),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      senderEmail,
                      style: TextStyle(
                        color: isCurrentUser
                            ? tema.setentaCorFraca
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (imageUrl != null && isVideo == "video") // Verifica se é um vídeo
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExibirImagemPage(
                      imageUrl: imageUrl,
                      isVideo: isVideo,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? tema.mensagemUserColor
                          : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border(
                        top: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 33.0,
                        ),
                        bottom: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 5.0,
                        ),
                        right: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 5.0,
                        ),
                        left: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 5.0,
                        ),
                      ),
                    ),
                    child: Container(
                      color: const Color.fromARGB(255, 0, 34, 73),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      senderEmail,
                      style: TextStyle(
                        color: isCurrentUser
                            ? tema.setentaCorFraca
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (imageUrl != null && isVideo == "pdf") // Verifica se é um vídeo
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExibirImagemPage(
                      imageUrl: imageUrl,
                      isVideo: isVideo,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? tema.mensagemUserColor
                          : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border(
                        top: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 33.0,
                        ),
                        bottom: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 5.0,
                        ),
                        right: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 5.0,
                        ),
                        left: BorderSide(
                          color: isCurrentUser
                              ? tema.mensagemUserColor
                              : Colors.blueAccent,
                          width: 5.0,
                        ),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.red,
                      child: const Text("PDF",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 80,
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      senderEmail,
                      style: TextStyle(
                        color: isCurrentUser
                            ? tema.setentaCorFraca
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (imageUrl == null)
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              decoration: BoxDecoration(
                color:
                    isCurrentUser ? tema.mensagemUserColor : Colors.blueAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      senderEmail,
                      style: TextStyle(
                        color: isCurrentUser
                            ? tema.setentaCorFraca
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(color: tema.pretoEBrancoColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: tema.cabecarioColor,
        borderRadius:
            BorderRadius.circular(8.0), // Define a borda arredondada aqui
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showPopupMenu(context),
            icon: const Icon(
              Icons.add,
              color: Colors.blueAccent,
              size: 45,
            ),
          ),
          Expanded(
            child: Preencha(
              controller: _messageController,
              hintText: "Digite sua mensagem",
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
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

  void sendMessage() async {
    if (_messageController.text.isNotEmpty && !_imagemEnviada) {
      await _chatService.enviarMessage(
        widget.resiverUserID,
        _messageController.text,
      );

      _messageController.clear();
    }
  }

  Future<XFile?> getMedia(String vaiSairDa, bool pdf) async {
    final ImagePicker picker = ImagePicker();
    XFile? media;
    if (pdf == true) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        media = XFile(result.files.single.path!);
        setState(() {
          opcoes = 1;
        });
      }
    } else {
      final MediaType? mediaType = await showDialog<MediaType>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: tema.popUplColor,
            title: Text(
              "Selecionar Mídia",
              textAlign: TextAlign.center,
              style: TextStyle(color: tema.pretoEBrancoColor, fontSize: 30),
            ),
            contentPadding: const EdgeInsets.only(
              top: 20,
            ),
            content: SizedBox(
              width: 350,
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, MediaType.image),
                    child: Column(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: tema.setentaCorFraca,
                          size: 80,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Imagens",
                          style:
                              TextStyle(color: Colors.blueAccent, fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, MediaType.video),
                    child: Column(
                      children: [
                        Icon(
                          Icons.video_file_outlined,
                          color: tema.setentaCorFraca,
                          size: 80,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Videos",
                          style:
                              TextStyle(color: Colors.blueAccent, fontSize: 20),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (mediaType != null) {
        switch (vaiSairDa) {
          case "galeria":
            switch (mediaType) {
              case MediaType.image:
                media = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                setState(() {
                  opcoes = 2;
                });

                break;
              case MediaType.video:
                media = await picker.pickVideo(
                  source: ImageSource.gallery,
                );
                setState(() {
                  opcoes = 3;
                });
                break;
            }
            break;
          case "camera":
            switch (mediaType) {
              case MediaType.image:
                media = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                );
                setState(() {
                  opcoes = 2;
                });
                break;
              case MediaType.video:
                media = await picker.pickVideo(
                  source: ImageSource.camera,
                );
                setState(() {
                  opcoes = 3;
                });
                break;
            }
            break;
        }
      }
    }

    return media;
  }

  Future<void> uplaod(String path, String userId,
      {required String isVideo}) async {
    File file = File(path);
    String ref = "";

    try {
      switch (isVideo) {
        case "foto":
          ref = "Usuarios/$userId/images/img_${DateTime.now().toString()}.jpg";
          break;
        case "video":
          ref = "Usuarios/$userId/videos/vid_${DateTime.now().toString()}.mp4";
          break;
        case "pdf":
          ref =
              "Usuarios/$userId/Documentos/vid_${DateTime.now().toString()}.pdf";
          break;
        default:
      }

      UploadTask task = _storage.ref(ref).putFile(file);
      task.snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          if (snapshot.state == TaskState.success) {
            String mediaUrl = await snapshot.ref.getDownloadURL();

            await _chatService.enviarImage(
              widget.resiverUserID,
              mediaUrl,
              _messageController.text,
              isVideo,
            );

            // setState(() => _lastImageUrl = mediaUrl);
          }
        },
      );
    } on FirebaseException catch (e) {
      throw Exception("Erro no upload: ${e.code}");
    }
  }

  pickAndUploadImage({
    required String vaiSairDa,
    required bool pdf,
  }) async {
    XFile? file = await getMedia(vaiSairDa, pdf);
    if (file != null) {
      switch (opcoes) {
        case 1:
          await uplaod(file.path, widget.resiverUserID, isVideo: "pdf");

          break;
        case 2:
          await uplaod(file.path, widget.resiverUserID, isVideo: "foto");

          break;
        case 3:
          await uplaod(file.path, widget.resiverUserID, isVideo: "video");

          break;

        default:
      }
    }
  }

  void _showPopupMenu(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(0, overlay.size.height, 0, 0),
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            leading: Icon(
              Icons.image_outlined,
              color: tema.setentaCorFraca,
            ),
            title: Text(
              'Galeria',
              style: TextStyle(
                color: tema.pretoEBrancoColor,
              ),
            ),
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: ListTile(
            leading: Icon(
              Icons.picture_as_pdf_outlined,
              color: tema.setentaCorFraca,
            ),
            title: Text(
              'PDF',
              style: TextStyle(
                color: tema.pretoEBrancoColor,
              ),
            ),
          ),
        ),
        PopupMenuItem<int>(
          value: 3,
          child: ListTile(
            leading: Icon(
              Icons.camera_alt_outlined,
              color: tema.setentaCorFraca,
            ),
            title: Text(
              'Camera',
              style: TextStyle(
                color: tema.pretoEBrancoColor,
              ),
            ),
          ),
        ),
      ],
      color: tema.popUplColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
    );
    if (selected != null) {
      switch (selected) {
        case 1:
          pickAndUploadImage(
            vaiSairDa: "galeria",
            pdf: false,
          );
          break;
        case 2:
          pickAndUploadImage(
            vaiSairDa: "pdf",
            pdf: true,
          );
          break;
        case 3:
          pickAndUploadImage(
            vaiSairDa: "camera",
            pdf: false,
          );
          break;
        default:
      }
    }
  }
}

enum MediaType {
  image,
  video,
}
