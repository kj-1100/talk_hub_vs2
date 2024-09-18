// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/botazin.dart';
import 'package:talk_hub_vs2/componentes/meus_preencha.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';
import 'package:talk_hub_vs2/pages/chat/Conver%C3%A7as%20Um%20pra%20Um/amigos.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/autenticando_servico.dart';

class CriandoGrupo extends StatefulWidget {
  const CriandoGrupo({Key? key, this.onTap}) : super(key: key);
  final void Function()? onTap;

  @override
  State<CriandoGrupo> createState() => _CriandoGrupoState();
}

class _CriandoGrupoState extends State<CriandoGrupo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController confirmaSenhaController;
  late TextEditingController groupDescription;
  late TextEditingController groupName;
  late FirebaseStorage _storage;
  late AuthService authService;
  late TemaDoApp tema;
  String? _fotoPerfil;
  late String userId;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    tema = Provider.of<TemaDoApp>(context, listen: false);
    confirmaSenhaController = TextEditingController();
    userId = FirebaseAuth.instance.currentUser!.uid;
    groupDescription = TextEditingController();
    groupName = TextEditingController();
    _storage = FirebaseStorage.instance;
  }

  void registrar() async {
    try {
      await criandoGrupo(
          groupName.text, groupDescription.text, _fotoPerfil ?? '', userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Grupo criado com sucesso",
          ),
        ),
      );

      Navigator.pop(
        context,
        MaterialPageRoute(builder: (context) => const InicialPage()),
      );
    } catch (e) {
      print("Erro ao registrar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Falha no registro. Verifique o console para mais detalhes.",
          ),
        ),
      );
    }
  }

  void registrarEAdicionar() async {
    try {
      String groupId = await criandoGrupo(
          groupName.text, groupDescription.text, _fotoPerfil ?? '', userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Grupo criado com sucesso",
          ),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AmigosPage(
            userId: userId,
            addGrupo: true,
            groupId: groupId, // Passar o groupId para a próxima tela
            nomeDoGrupo: groupName.text,
          ),
        ),
      );
    } catch (e) {
      print("Erro ao registrar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Falha no registro. Verifique o console para mais detalhes.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tema.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 46, 114),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(
                  height: 75,
                ),
                GestureDetector(
                  onTap: mandarFotoGrupoNuvem,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: _fotoPerfil != null
                        ? NetworkImage(_fotoPerfil!)
                        : null, // Se _fotoPerfil for nulo, backgroundImage será nulo
                    child: _fotoPerfil == null
                        ? const Icon(Icons.group, size: 40)
                        : null, // Adicione o ícone apenas quando _fotoPerfil for nulo
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Text(
                  "Clique acima para adionar foto de perfil",
                  style: TextStyle(color: tema.pretoEBrancoColor, fontSize: 18),
                ),
                const SizedBox(
                  height: 15,
                ),
                //email
                Preencha(
                  controller: groupName,
                  hintText: "Nome grupo",
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                //apelido
                Preencha(
                  controller: groupDescription,
                  hintText: "Decrição Grupo",
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Botao(
                      onTap: () {
                        if (groupName.text != "") {
                          registrar();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                "Por favor inserir um nome válido.",
                              ),
                            ),
                          );
                        }
                      },
                      texto: "Criar Grupo"),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (groupName.text != "") {
                        registrarEAdicionar();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Por favor inserir um nome válido.",
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: 150,
                      child: Center(
                        child: Text(
                          "Criar e Add Amigos",
                          style: TextStyle(
                              color: tema.pretoEBrancoColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> criandoGrupo(
    String groupName,
    String groupDescription,
    String? groupPhotoUrl,
    String userId,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Usuário não está autenticado.');
      }

      DocumentReference userDocRef =
          _firestore.collection("Usuario").doc(user.uid);
      DocumentSnapshot userDocSnapshot = await userDocRef.get();

      if (!userDocSnapshot.exists) {
        throw Exception('Documento do usuário não encontrado.');
      }

      DocumentReference groupDocRef = _firestore.collection("grupos").doc();
      String groupId = groupDocRef.id;

      await groupDocRef.set({
        "groupId": groupId,
        "groupName": groupName,
        "groupDescription": groupDescription,
        "groupPhotoUrl": groupPhotoUrl ?? "",
        "adminUid": user.uid,
        "members": {user.uid: true},
        "timestamp": FieldValue.serverTimestamp(),
      });

      await userDocRef.update({
        "groups.$groupId": true,
      });

      return groupId;
    } catch (e) {
      throw Exception("Erro ao criar grupo: $e");
    }
  }

  Future<XFile?> pegarFotoGrupo() async {
    final ImagePicker picker = ImagePicker();
    XFile? fotoPerfil = await picker.pickImage(source: ImageSource.gallery);
    return fotoPerfil;
  }

  Future<UploadTask> mandarFotoGrupo(
      String path, String userId, String groupId) async {
    File file = File(path);
    try {
      String ref = "Grupos/$userId/Foto_Grupos/img_fotoGroup$groupId.jpg";
      return _storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception("Erro ao enviar foto: ${e.code}");
    }
  }

  Future<void> mandarFotoGrupoNuvem() async {
    XFile? file = await pegarFotoGrupo();
    if (file != null) {
      UploadTask task =
          await mandarFotoGrupo(file.path, userId, UniqueKey().toString());
      task.snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          if (snapshot.state == TaskState.running) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Enviando Foto'),
                backgroundColor: Colors.blueAccent,
              ),
            );
          } else if (snapshot.state == TaskState.success) {
            String groupPhotoUrl = await snapshot.ref.getDownloadURL();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto Enviada'),
                backgroundColor: Colors.blueAccent,
              ),
            );
            setState(() => _fotoPerfil = groupPhotoUrl);

            try {
              await atualizarFotoGrupo(groupPhotoUrl);
            } catch (e) {
              print("Erro ao atualizar a foto do grupo: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Falha ao atualizar a foto do grupo. Verifique o console para mais detalhes.",
                  ),
                ),
              );
            }
          } else if (snapshot.state == TaskState.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ocorreu Algum Erro. Tente Novamente'),
                backgroundColor: Colors.blueAccent,
              ),
            );
          }
        },
      );
    }
  }

  Future<void> atualizarFotoGrupo(String groupPhotoUrl) async {
    try {
      String groupId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("grupos")
          .doc(groupId)
          .update({
        "groupPhotoUrl": groupPhotoUrl,
      });
    } catch (e) {
      throw Exception("Erro ao atualizar a foto de perfil: $e");
    }
  }
}
