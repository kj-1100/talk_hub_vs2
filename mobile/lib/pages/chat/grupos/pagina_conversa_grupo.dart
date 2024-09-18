// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/meus_preencha.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/chat/Conver%C3%A7as%20Um%20pra%20Um/amigos.dart';
import 'package:talk_hub_vs2/pages/chat/Conver%C3%A7as%20Um%20pra%20Um/chat_service.dart';
import 'package:talk_hub_vs2/pages/chat/exibir_imagem.dart';

class PaginaConversaGrupo extends StatefulWidget {
  final String groupId;
  final String groupName;

  const PaginaConversaGrupo({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  State<PaginaConversaGrupo> createState() => _PaginaConversaGrupoState();
}

class _PaginaConversaGrupoState extends State<PaginaConversaGrupo> {
  final TextEditingController editNomeGrupoController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storageimagens = FirebaseStorage.instance;
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  List<DocumentSnapshot> invitations = [];
  late String nomeDoGrupo;
  String? _lastImageUrl;
  late TemaDoApp tema;
  int opcoes = 0;

  @override
  void initState() {
    tema = Provider.of<TemaDoApp>(context, listen: false);
    nomeDoGrupo = widget.groupName;
    super.initState();
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
        actions: [
          IconButton(
              onPressed: () => opcoesDoGrupo(
                  context), // Função anônima que chama opcoesDoGrupo com o parâmetro BuildContext
              icon: Icon(
                Icons.more_vert,
                color: tema.pretoEBrancoColor,
              )),
        ],
        title: Text(
          nomeDoGrupo,
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
      stream: _chatService.getGroupMessages(widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
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

    String senderEmail = data["senderEmail"] ?? "Unknown user";
    String message = data["message"] ?? "Empty message";
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
          if (imageUrl != null && isVideo == "foto")
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
          if (imageUrl != null && isVideo == "video")
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
          if (imageUrl != null && isVideo == "pdf")
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
        borderRadius: BorderRadius.circular(8.0),
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
    if (_messageController.text.isNotEmpty || _lastImageUrl != null) {
      await _chatService.enviarMenssageGrupo(
        widget.groupId,
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
            print("galeria2");
            switch (mediaType) {
              case MediaType.image:
                media = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                setState(() {
                  opcoes = 2;
                });
                print("galeriafoi1");
                break;
              case MediaType.video:
                media = await picker.pickVideo(
                  source: ImageSource.gallery,
                );

                setState(() {
                  opcoes = 3;
                });
                print("galeriafoi2");
                break;
            }
            break;
          case "camera":
            print("camera2");
            switch (mediaType) {
              case MediaType.image:
                media = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                );
                setState(() {
                  opcoes = 2;
                });
                print("camerafoi1");
                break;
              case MediaType.video:
                media = await picker.pickVideo(
                  source: ImageSource.camera,
                );

                setState(() {
                  opcoes = 3;
                });
                print("camerafoi2");
                break;
            }
            break;
        }
      }
    }
    print("Mídia selecionada: ${media?.path}");
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

      UploadTask task = storageimagens.ref(ref).putFile(file);
      task.snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          if (snapshot.state == TaskState.success) {
            String mediaUrl = await snapshot.ref.getDownloadURL();

            // Enviar a imagem ou vídeo e obter a URL
            await _chatService.enviarImage(
              widget.groupId,
              mediaUrl,
              _messageController.text,
              isVideo,
            );
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
          await uplaod(file.path, widget.groupId, isVideo: "pdf");

          break;
        case 2:
          await uplaod(file.path, widget.groupId, isVideo: "foto");

          break;
        case 3:
          await uplaod(file.path, widget.groupId, isVideo: "video");

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
          print("galeria1");
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
          print("camera1");
          break;
        default:
      }
    }
  }

  void opcoesDoGrupo(
    BuildContext context,
  ) async {
    User? currentUser = _firebaseAuth.currentUser;
    String groupId = widget.groupId;
    late String userId = currentUser!.uid;
    final selected = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 24.0,
        kToolbarHeight + MediaQuery.of(context).padding.top,
        MediaQuery.of(context).size.width - 16.0,
        kToolbarHeight + 48.0 + MediaQuery.of(context).padding.top,
      ),
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            leading: Icon(
              Icons.edit,
              color: tema.setentaCorFraca,
            ),
            title: Text(
              'Mudar nome grupo',
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
              Icons.image,
              color: tema.setentaCorFraca,
            ),
            title: Text(
              'Foto do grupo',
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
              Icons.person_add_outlined,
              color: tema.setentaCorFraca,
            ),
            title: Text(
              'Adicinar mais pessoas',
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
          _editGroupName();
          break;
        case 2:
          _selectGroupPhoto();

          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AmigosPage(
                userId: userId,
                addGrupo: true,
                groupId: groupId,
                nomeDoGrupo: nomeDoGrupo,
              ),
            ),
          );
          break;
        default:
      }
    }
  }

  void _selectGroupPhoto() async {
    XFile? imageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      await _uploadGroupPhoto(imageFile.path);
    }
  }

  Future<void> _uploadGroupPhoto(String imagePath) async {
    File file = File(imagePath);
    String groupId = widget.groupId;
    String photoUrl = 'Grupos/$groupId/group_photo.jpg';

    try {
      await storageimagens.ref(photoUrl).putFile(file);

      String downloadUrl = await storageimagens.ref(photoUrl).getDownloadURL();

      await FirebaseFirestore.instance
          .collection('grupos')
          .doc(groupId)
          .update({
        'groupPhotoUrl': downloadUrl,
      });

      // Feedback ao usuário
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Foto do grupo atualizada com sucesso!'),
      ));
    } catch (e) {
      print('Erro ao atualizar a foto do grupo: $e');
      // Feedback ao usuário em caso de erro
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erro ao atualizar a foto do grupo.'),
      ));
    }
  }

  void _editGroupName() async {
    String? newName = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tema.popUplColor,
        title: Text(
          'Editar Nome do Grupo',
          style: TextStyle(color: tema.pretoEBrancoColor),
        ),
        content: TextField(
          cursorColor: Colors.blueAccent,
          controller: editNomeGrupoController, // Adicione o controller
          style: TextStyle(color: tema.pretoEBrancoColor),
          decoration: InputDecoration(
            hintText: 'Novo nome do grupo',
            hintStyle: TextStyle(color: tema.corFraca),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                  color: Color.fromARGB(179, 255, 68, 68), fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, editNomeGrupoController.text.trim());
              setState(() {});
            },
            child: const Text(
              'Salvar',
              style: TextStyle(
                  color: Color.fromARGB(148, 68, 137, 255), fontSize: 18),
            ),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        nomeDoGrupo = newName;
      });

      await _updateGroupName(newName);
    }
  }

  Future<void> _updateGroupName(String newName) async {
    String groupId = widget.groupId;

    try {
      await _firestore.collection('grupos').doc(groupId).update({
        'groupName': newName,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Nome do grupo atualizado para $newName'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print('Erro ao atualizar o nome do grupo: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erro ao atualizar o nome do grupo.'),
        backgroundColor: Colors.red,
      ));
    }
  }
}

enum MediaType { image, video }
