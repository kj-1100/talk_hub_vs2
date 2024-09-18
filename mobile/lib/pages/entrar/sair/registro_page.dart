// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/botazin.dart';
import 'package:talk_hub_vs2/componentes/meus_preencha.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/autenticando_servico.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key, required this.onTap});
  final void Function()? onTap;
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final confirmaSenhaController = TextEditingController();
  final apelidoController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool confirmrObscureSenha = true;
  bool obscureSenha = true;
  String? _fotoPerfil;
  late TemaDoApp tema;

  @override
  void initState() {
    tema = Provider.of<TemaDoApp>(context, listen: false);
    super.initState();
  }

  Future<XFile?> pegarFotoPerfil() async {
    final ImagePicker piker = ImagePicker();
    XFile? fotoPerfil = await piker.pickImage(source: ImageSource.gallery);
    return fotoPerfil;
  }

  Future<UploadTask> mandarFotoperfi(String path, String email) async {
    File file = File(path);
    try {
      String ref = "$email/Foto_Perfil/img_fotoUsuario.jpg";
      return _storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception("Erro ao enviar foto: ${e.code}");
    }
  }

  mandarFotoPerfilNuvem() async {
    XFile? file = await pegarFotoPerfil();
    if (file != null) {
      UploadTask task = await mandarFotoperfi(file.path, "senderId");
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
            String fotoperfilUrl = await snapshot.ref.getDownloadURL();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto Enviada'),
                backgroundColor: Colors.blueAccent,
              ),
            );
            setState(() => _fotoPerfil = fotoperfilUrl);

            try {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.atualizarFotoPerfil(fotoperfilUrl);
            } catch (e) {
              print("Erro ao atualizar a foto de perfil: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Falha ao atualizar a foto de perfil. Verifique o console para mais detalhes.",
                  ),
                ),
              );
            }
          } else if (snapshot.state == TaskState.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ocorreu Algum Erro Tente De Novo'),
                backgroundColor: Colors.blueAccent,
              ),
            );
          }
        },
      );
    }
  }

  void registrar() async {
    if (senhaController.text != confirmaSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Senhas diferentes",
          ),
        ),
      );
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // Chame o método criandoContaEmailSenha com a URL da foto de perfil
      await authService.criandoContaEmailSenha(
        emailController.text,
        senhaController.text,
        apelidoController.text,
        _fotoPerfil ?? '', // Se _fotoPerfil for nulo, passe uma string vazia
      );
    } catch (e) {
      print("Erro ao registrar: $e");
      if (e.toString().contains("invalid-email")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Por favor inserir um e-mail válido.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Falha no registro. Verifique o console para mais detalhes.",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tema.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                //logo
                const Icon(
                  Icons.message,
                  size: 90,
                  color: Colors.blueAccent,
                ),
                const SizedBox(
                  height: 35,
                ),
                 Text(
                  "Crie uma conta e divirta-se ! :D",
                  style: TextStyle(color:tema.pretoEBrancoColor, fontSize: 18),
                ),
                //saudação
                const SizedBox(
                  height: 35,
                ),
                GestureDetector(
                  onTap: mandarFotoPerfilNuvem,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: _fotoPerfil != null
                        ? NetworkImage(_fotoPerfil!)
                        : const AssetImage("assets/images/account_circle.png")
                            as ImageProvider,
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
                PreenchaEmail(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                //apelido
                Preencha(
                  controller: apelidoController,
                  hintText: "Nome de Usuario",
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                //senha
                PreenchaSenha(
                  controller: senhaController,
                  hintText: "Senha",
                  obscureText: obscureSenha,
                ),
                const SizedBox(
                  height: 10,
                ),
                //senha confirme
                PreenchaSenha(
                  controller: confirmaSenhaController,
                  hintText: "Confirma Senha",
                  obscureText: confirmrObscureSenha,
                ),

                const SizedBox(
                  height: 10,
                ),
                Botao(onTap: registrar, texto: "Registrar"),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "já é membro?",
                      style: TextStyle(color: tema.setentaCorFraca),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Conecte-se",
                        style: TextStyle(color: tema.pretoEBrancoColor),
                      ),
                    )
                  ],
                ),
                // Adicione um espaço para evitar que o teclado cubra os elementos
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
