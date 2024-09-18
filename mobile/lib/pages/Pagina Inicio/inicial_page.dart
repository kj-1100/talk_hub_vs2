// ignore_for_file: avoid_print, use_build_context_synchronously, avoid_function_literals_in_foreach_calls

import 'dart:io';
// ignore: unnecessary_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_hub_vs2/componentes/botazin.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/selecionar_icones_tela_principal.dart';
import 'package:talk_hub_vs2/pages/chat/Conver%C3%A7as%20Um%20pra%20Um/amigos.dart';
import 'package:talk_hub_vs2/pages/chat/Conver%C3%A7as%20Um%20pra%20Um/pagina_convera.dart';
import 'package:talk_hub_vs2/pages/chat/Solicita%C3%A7%C3%B5es/notifica%C3%A7%C3%A3o_page.dart';
import 'package:talk_hub_vs2/pages/chat/Solicita%C3%A7%C3%B5es/procurar_page.dart';
import 'package:talk_hub_vs2/pages/chat/grupos/grupos.dart';
import 'package:talk_hub_vs2/pages/botSuport/telabot.dart';
import 'package:talk_hub_vs2/pages/chat/paradinha_do_chat.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/autenticando_servico.dart';
import 'package:talk_hub_vs2/pages/notas/delete_nota.dart';
import 'package:talk_hub_vs2/pages/notas/minhas_notas.dart';
import 'package:talk_hub_vs2/pages/notas/nova_Nota.dart';

class InicialPage extends StatefulWidget {
  final bool? anuncioAddIconTelaInicial;
  final List<bool>? manterStatus;

  final bool? recarregar;

  const InicialPage({
    Key? key,
    this.manterStatus,
    this.recarregar,
    this.anuncioAddIconTelaInicial,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InicialPageState();
}

class _InicialPageState extends State<InicialPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late List<bool> iconesVisiveissalvos = [];
  late List<String> amigosFavoritos = [];
  late AmigosEGrupoService amigoEgrupo;
  late List<int> iconesVisiveis = [];
  late bool anuncioIconeTelaInicial;
  late List<bool>? iconesNaTela;
  late AuthService authService;
  bool isLoading = true;
  late bool recarregar;
  String? _fotoPerfil;
  late TemaDoApp tema;

  @override
  void initState() {
    amigoEgrupo = Provider.of<AmigosEGrupoService>(context, listen: false);
    anuncioIconeTelaInicial = widget.anuncioAddIconTelaInicial ?? true;
    authService = Provider.of<AuthService>(context, listen: false);
    tema = Provider.of<TemaDoApp>(context, listen: false);
    iconesNaTela = widget.manterStatus;
    recarregar = widget.recarregar ?? true;
    carregarFotoPerfil();
    super.initState();
    salvar();
    carregarIconesVisiveis().then((iconesSalvos) {
      setState(() {
        iconesVisiveissalvos = iconesSalvos;
      });
    });
    if (recarregar == true) {
      setState(() {
        recarregar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 35,
              ),
              child: Text(
                "::.TalkHUB.::",
                style: TextStyle(color: tema.pretoEBrancoColor),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: tema.pretoEBrancoColor,
              ),
              onPressed: () {
                _showPopupMenu(context);
              },
            ),
          ],
          backgroundColor: tema.cabecarioColor,
          iconTheme: const IconThemeData(color: Colors.blueAccent),
        ),
        drawer: Drawer(
          backgroundColor: tema.backgroundColor,
          //const Color.fromARGB(255, 23, 33, 46),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildHeader(context),
                buildMenuItems(),
              ],
            ),
          ),
        ),
        backgroundColor: tema.backgroundColor,
        extendBodyBehindAppBar: true,
        extendBody: true, //
        body: buildTelaPrincipal(context),
      ),
    );
  }

  Widget buildTelaPrincipal(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const iconSize = 128.0;
    final columns = (screenWidth / iconSize).floor();

    List<Widget> childrenWidgets = [];

    // Verifica se há ícones visíveis para exibir
    if (iconesNaTela != null && iconesNaTela!.isNotEmpty) {
      iconesVisiveis.clear();
      for (int i = 0; i < iconesNaTela!.length; i++) {
        if (iconesNaTela![i]) {
          iconesVisiveis.add(i);
        }
      }
    } else if (iconesVisiveissalvos.isNotEmpty) {
      iconesVisiveis.clear();
      setState(() {
        anuncioIconeTelaInicial = false;
      });
      for (int i = 0; i < iconesVisiveissalvos.length; i++) {
        if (iconesVisiveissalvos[i]) {
          iconesVisiveis.add(i);
        }
      }
    }

    // Adiciona ícones visíveis à lista de widgets
    childrenWidgets.addAll(
      List.generate(
        amigosFavoritos.length,
        (index) => _buildAmigoItem(index),
      ),
    );

    // Adiciona itens de amigos à lista de widgets
    childrenWidgets.addAll(
      iconesVisiveis.map((index) => _buildIconButton(index)),
    );

    return Scaffold(
      backgroundColor: tema.backgroundColor,
      body: Container(
        child: anuncioIconeTelaInicial
            ? Container(
                alignment: Alignment.center,
                child: Card(
                  margin: const EdgeInsets.all(20),
                  color: tema.popUplColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Você ainda não adicionou nenhum ícone aos favoritos.",
                          style: TextStyle(
                            color: tema.pretoEBrancoColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Botao(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const IconesNaTela(),
                                  ),
                                );
                              },
                              texto: "Adicionar",
                            ),
                            const SizedBox(width: 20),
                            Botao(
                              onTap: () {
                                setState(() {
                                  anuncioIconeTelaInicial = false;
                                  iconesVisiveissalvos = List.filled(11, false);
                                  iconesNaTela = List.filled(11, false);
                                  salvar();
                                });
                              },
                              texto: "Parar",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: columns,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      children: childrenWidgets,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // WIDGET local onde fica foto e nome do usuario
  Widget buildHeader(BuildContext context) {
    AuthService authService = Provider.of<AuthService>(context, listen: false);

    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      color: tema.cabecarioColor,
      child: Column(
        children: [
          const SizedBox(height: 12.0),
          GestureDetector(
            onTap: opcaoFotoPerfil,
            child: CircleAvatar(
              backgroundColor:
                  tema.isDarkMode ? Colors.black : tema.backgroundColor,
              radius: 75,
              backgroundImage:
                  _fotoPerfil != null ? NetworkImage(_fotoPerfil!) : null,
              child: _fotoPerfil == null
                  ? Icon(
                      Icons.person,
                      size: 75,
                      color: tema.pretoEBrancoColor,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10.0),
          FutureBuilder<String>(
            future: authService.getUserApelido(_auth.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  color: Colors.blueAccent,
                );
              } else if (snapshot.hasError) {
                return const Text('Erro ao obter nome de usuário');
              } else {
                return Text(
                  snapshot.data ?? "",
                  style: TextStyle(
                    color: tema.pretoEBrancoColor,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  // WIDGET os botoes pricipais
  Widget buildMenuItems() => AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: Column(
          children: [
            // VOLTA PAGINA INICIAL
            ListTile(
              leading: Icon(Icons.home_rounded, color: tema.pretoEBrancoColor),
              title:
                  Text("Casa", style: TextStyle(color: tema.pretoEBrancoColor)),
              subtitle: const Text("Pagina Inicial",
                  style: TextStyle(color: Colors.blueAccent)),
              onTap: () {},
            ),

            // Opções grupos
            ExpansionTile(
              leading:
                  Icon(Icons.groups_outlined, color: tema.pretoEBrancoColor),
              iconColor: Colors.blueAccent,
              title: Text("Conversas",
                  style: TextStyle(color: tema.pretoEBrancoColor)),
              subtitle: const Text("Opções Conversas",
                  style: TextStyle(color: Colors.blueAccent)),
              children: [buildCovecas()],
            ),

            // Opções notas
            ExpansionTile(
              leading: Icon(Icons.notes_sharp, color: tema.pretoEBrancoColor),
              iconColor: Colors.blueAccent,
              title: Text("Notas",
                  style: TextStyle(color: tema.pretoEBrancoColor)),
              subtitle: const Text("Opções Notas",
                  style: TextStyle(color: Colors.blueAccent)),
              children: [buildNotes()],
            ),

            // Opções User
            ExpansionTile(
              leading: Icon(Icons.settings, color: tema.pretoEBrancoColor),
              iconColor: Colors.blueAccent,
              title: Text("Configurações",
                  style: TextStyle(color: tema.pretoEBrancoColor)),
              subtitle: const Text("Edite Suas Preferências",
                  style: TextStyle(color: Colors.blueAccent)),
              children: [buildConfigura()],
            ),
          ],
        ),
      );

  // WIDGET GRUPOS
  Widget buildCovecas() => Column(
        children: [
          ListTile(
            leading: Icon(Icons.person_add, color: tema.pretoEBrancoColor),
            trailing: Icon(Icons.keyboard_arrow_right_outlined,
                color: tema.pretoEBrancoColor),
            title: Text("Usuários",
                style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("Crie conexões",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_outlined,
                color: tema.pretoEBrancoColor),
            trailing: Icon(Icons.keyboard_arrow_right_outlined,
                color: tema.pretoEBrancoColor),
            title: Text("Solicitações e Convites",
                style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text(
                "Veja seus pedidos de amizade e convites para grupos",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SolicitacoesDeAmizade()));
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: tema.pretoEBrancoColor),
            trailing: Icon(Icons.keyboard_arrow_right_outlined,
                color: tema.pretoEBrancoColor),
            title:
                Text("Amigos", style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("Veja suas conexões",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AmigosPage(
                    userId: _auth.currentUser!.uid,
                    addGrupo: false,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.group, color: tema.pretoEBrancoColor),
            trailing: Icon(Icons.keyboard_arrow_right_outlined,
                color: tema.pretoEBrancoColor),
            title:
                Text("Grupos", style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("Converse com vários amigos juntos",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Grupos(userId: _auth.currentUser!.uid),
                ),
              );
            },
          ),
        ],
      );

  // WIDGET NOTAS
  Widget buildNotes() => Column(
        children: [
          ListTile(
            leading:
                Icon(Icons.note_add_outlined, color: tema.pretoEBrancoColor),
            trailing: Icon(Icons.keyboard_arrow_right_outlined,
                color: tema.pretoEBrancoColor),
            title:
                Text("Nova", style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("Criar notas",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NovaNota(),
                ),
              );
            },
          ),

          // Ver notas
          ListTile(
            leading: Icon(Icons.note_outlined, color: tema.pretoEBrancoColor),
            trailing: Icon(Icons.keyboard_arrow_right_outlined,
                color: tema.pretoEBrancoColor),
            title:
                Text("notas", style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("Visualizar notas",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExibirNota(),
                ),
              );
            },
          ),

          // Deletar nota
          ListTile(
            leading: SizedBox(
              height: 25,
              child: Image.asset("assets/icons/outline_note_delete.png",
                  color: tema.pretoEBrancoColor),
            ),
            trailing: Icon(Icons.keyboard_arrow_right_outlined,
                color: tema.pretoEBrancoColor),
            title: Text("Deletar",
                style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("Excluir notas",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteNota(),
                ),
              );
            },
          ),
        ],
      );

  //WIDGET CONFIGURAÇÕES
  Widget buildConfigura() => Column(
        children: [
          ListTile(
            leading: Icon(Icons.account_circle, color: tema.pretoEBrancoColor),
            title: Text("Foto Perfil",
                style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("Editar foto perfil",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              opcaoFotoPerfil();
            },
          ),
          ListTile(
            leading: Icon(Icons.edit, color: tema.pretoEBrancoColor),
            title: Text("Editar Nome",
                style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("Alterar o nome",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              editarApelido();
            },
          ),
          ListTile(
            leading: iconeDarkMode(),
            title:
                Text("Tema ", style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text(
                "Muda o estilo de cores do app para um mais claro",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              tema.toggleDarkMode();
              setState(() {});
            },
          ),
          ListTile(
            leading: SizedBox(
              height: 30,
              child: Image.asset("assets/icons/chatBot.png",
                  color: tema.pretoEBrancoColor),
            ),
            trailing: Icon(Icons.keyboard_arrow_right_outlined,
                color: tema.pretoEBrancoColor),
            title:
                Text("Ajuda", style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("entre em contato com nosso bot de suporte",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatBotPage(userId: _auth.currentUser!.uid),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: tema.pretoEBrancoColor),
            title: Text("Deslogar",
                style: TextStyle(color: tema.pretoEBrancoColor)),
            subtitle: const Text("Sair da sessão ",
                style: TextStyle(color: Colors.blueAccent)),
            onTap: () {
              sairConta();
            },
          ),
        ],
      );

  void sairConta() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.sairConta();
  }

  void editarApelido() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String novoApelido = '';
        return AlertDialog(
          backgroundColor: tema.botoesTelaInicialColor,
          title: Text(
            "Editar Apelido",
            style: TextStyle(color: tema.pretoEBrancoColor),
          ),
          content: TextField(
            cursorColor: Colors.blueAccent,
            onChanged: (value) {
              novoApelido = value;
            },
            style: TextStyle(color: tema.pretoEBrancoColor),
            decoration: InputDecoration(
              hintText: "Novo Apelido",
              hintStyle: TextStyle(color: tema.corFraca),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(
                    color: Color.fromARGB(179, 255, 68, 68), fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                authService.atualizarApelido(novoApelido);
                print("Novo Apelido: $novoApelido");
                setState(() {});
              },
              child: const Text(
                "Salvar",
                style: TextStyle(
                    color: Color.fromARGB(179, 68, 137, 255), fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  void salvar() async {
    if (iconesNaTela != null) {
      salvarIconesVisiveis(iconesNaTela!);
    } else {
      iconesNaTela = [];
    }
  }

  Future<void> salvarIconesVisiveis(List<bool> manterStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final iconesString =
        manterStatus.map((bool value) => value.toString()).toList();
    await prefs.setStringList('iconesNaTela', iconesString);
  }

  Future<List<bool>> carregarIconesVisiveis() async {
    final prefs = await SharedPreferences.getInstance();
    final iconesString = prefs.getStringList('iconesNaTela') ?? [];
    final iconesSalvos =
        iconesString.map((String value) => value == 'true').toList();

    setState(() {
      teste();
    });

    return iconesSalvos;
  }

  Future teste() async {
    amigosFavoritos = await tema.recuperarFavoritosLocalmente();
    return;
  }

  Future<void> carregarFotoPerfil() async {
    try {
      String userId = _auth.currentUser!.uid;
      String? url = await authService.getFotoPerfilUrl(userId);
      setState(() {
        _fotoPerfil = url;
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar foto de perfil: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> opcaoFotoPerfil() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tema.botoesTelaInicialColor,
          title: Text(
            "Deseja trocar ou deletar a foto de perfil ?",
            style: TextStyle(color: tema.pretoEBrancoColor),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await deletarFotoPerfil();
                Navigator.pop(context);
              },
              child: const Text(
                "deletar",
                style: TextStyle(
                    color: Color.fromARGB(179, 255, 68, 68), fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                mandarFotoPerfilNuvem();
                Navigator.pop(context);
              },
              child: const Text(
                "Trocar",
                style: TextStyle(
                    color: Color.fromARGB(179, 68, 137, 255), fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletarFotoPerfil() async {
    try {
      String userId = _auth.currentUser!.uid;
      String ref = "Usuario$userId/Foto_Perfil/img_fotoUsuario.jpg";

      await _storage.ref(ref).delete();

      setState(() => _fotoPerfil = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil deletada com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao deletar a foto de perfil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<XFile?> pegarFotoPerfil() async {
    final ImagePicker piker = ImagePicker();
    XFile? fotoPerfil = await piker.pickImage(source: ImageSource.gallery);
    return fotoPerfil;
  }

  Future<UploadTask> mandarFotoperfi(String path, String userId) async {
    File file = File(path);
    try {
      String ref = "Usuario$userId/Foto_Perfil/img_fotoUsuario.jpg";
      return _storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception("Erro ao enviar foto: ${e.code}");
    }
  }

  Widget iconeDarkMode() {
    switch (tema.isDarkMode) {
      case false:
        return Icon(Icons.light_mode, color: tema.pretoEBrancoColor);
      case true:
        return Icon(Icons.dark_mode, color: tema.pretoEBrancoColor);
      default:
        return SizedBox(
          height: 30,
          child: Image.asset("assets/icons/solnua_caso_tema_de_ruim.png",
              color: tema.pretoEBrancoColor),
        );
    }
  }

  mandarFotoPerfilNuvem() async {
    XFile? file = await pegarFotoPerfil();
    String userId = _auth.currentUser!.uid;

    if (file != null) {
      UploadTask task = await mandarFotoperfi(file.path, userId);
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
            String fotoParaDataBase = await snapshot.ref.getDownloadURL();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto Enviada'),
                backgroundColor: Colors.blueAccent,
              ),
            );

            try {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.atualizarFotoPerfil(fotoParaDataBase);
              String? fotoPerfilUrl =
                  await authService.getFotoPerfilUrl(userId);
              if (fotoPerfilUrl != null) {
                setState(() {
                  _fotoPerfil = fotoPerfilUrl;
                });
              }
            } catch (e) {
              print("Erro ao atualizar a foto de perfil: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
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

  Widget _getIconData(int index) {
    switch (index) {
      case 0:
        return Icon(
          Icons.person_add,
          color: tema.pretoEBrancoColor,
          size: 30,
        );
      case 1:
        return Icon(
          Icons.notifications_outlined,
          color: tema.pretoEBrancoColor,
          size: 30,
        );
      case 2:
        return Icon(
          Icons.person,
          color: tema.pretoEBrancoColor,
          size: 30,
        );
      case 3:
        return Icon(
          Icons.group,
          color: tema.pretoEBrancoColor,
          size: 30,
        );
      case 4:
        return Icon(
          Icons.account_circle,
          color: tema.pretoEBrancoColor,
          size: 30,
        );
      case 5:
        return Icon(Icons.edit, color: tema.pretoEBrancoColor);
      case 6:
        return SizedBox(
          height: 35,
          child: Image.asset("assets/icons/chatBot.png",
              color: tema.pretoEBrancoColor),
        );
      case 7:
        return Icon(
          Icons.note_add_outlined,
          color: tema.pretoEBrancoColor,
          size: 30,
        );
      case 8:
        return Icon(
          Icons.note_outlined,
          color: tema.pretoEBrancoColor,
          size: 30,
        );
      case 9:
        return SizedBox(
          height: 30,
          child: Image.asset("assets/icons/outline_note_delete.png",
              color: tema.pretoEBrancoColor),
        );
      case 10:
        return Icon(Icons.logout_outlined,
            color: tema.pretoEBrancoColor, size: 30);
      default:
        // Deletar nota
        return Icon(
          Icons.error,
          color: tema.pretoEBrancoColor,
          size: 30,
        );
    }
  }

  _getpaginaDesejada(int index) {
    switch (index) {
      case 0:
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => const UserPage()));
      case 1:
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SolicitacoesDeAmizade()));

      case 2:
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmigosPage(
              userId: _auth.currentUser!.uid,
              addGrupo: false,
            ),
          ),
        );
      case 3:
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Grupos(userId: _auth.currentUser!.uid),
          ),
        );
      case 4:
        return opcaoFotoPerfil();
      case 5:
        return editarApelido();
      case 6:
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatBotPage(userId: _auth.currentUser!.uid),
          ),
        );
      case 7:
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NovaNota(),
          ),
        );
      case 8:
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExibirNota(),
          ),
        );
      case 9:
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DeleteNota(),
          ),
        );
      case 10:
        return sairConta();
      default:
        return Icons.error;
    }
  }

  String _getButtonText(int index) {
    switch (index) {
      case 0:
        return "Usuários";
      case 1:
        return "Solicitações e Convites";
      case 2:
        return "Amigos";
      case 3:
        return "Grupos";
      case 4:
        return "Foto Perfil";
      case 5:
        return "Editar Nome";
      case 6:
        return "Ajuda";
      case 7:
        return "Nova Nota";
      case 8:
        return "Notas";
      case 9:
        return "Apagar Notas";
      case 10:
        return "Sair";
      default:
        return "Erro";
    }
  }

  Widget _buildAmigoItem(int index) {
    // Use amigosFavoritos para obter o ID do amigo correspondente ao índice
    if (index >= 0 && index < amigosFavoritos.length) {
      String friendUid = amigosFavoritos[index];

      return Card(
        color: Colors.blueAccent,
        child: SizedBox(
          width: 128,
          height: 129.5,
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: Material(
              color: tema.botoesTelaInicialColor,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () async {
                  List<dynamic> userData =
                      await amigoEgrupo.pegarInformacaoDoAmigo(friendUid);
                  String userName = userData[0];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaginaConvera(
                        resiveruserEmail: 'email_do_seu_amigo',
                        resiverUserID: friendUid,
                        resiverApelido: userName,
                        // Passando a URL da imagem de perfil
                      ),
                    ),
                  );
                },
                child: FutureBuilder(
                  future: amigoEgrupo.pegarInformacaoDoAmigo(friendUid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      List<dynamic> userData = snapshot.data as List<dynamic>;
                      String userName = userData[0];
                      String fotoPerfilUrl = userData[1];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 23,
                            backgroundImage: NetworkImage(fotoPerfilUrl),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userName,
                            style: TextStyle(
                              color: tema.pretoEBrancoColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    } else {
                      return const Text('Carregando...');
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return const Text(
          "data"); // Retorna null se o índice estiver fora do intervalo
    }
  }

  Widget _buildIconButton(int index) {
    return Card(
      color: Colors.blueAccent,
      child: SizedBox(
        width: 128,
        height: 129.5,
        child: Padding(
          padding: const EdgeInsets.all(1.5),
          child: Material(
            color: tema.botoesTelaInicialColor,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                _getpaginaDesejada(index);
              },
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  _getIconData(index),
                  const SizedBox(height: 17),
                  Text(
                    _getButtonText(index),
                    style: TextStyle(
                      color: tema.pretoEBrancoColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) async {
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
              Icons.library_add_outlined,
              color: tema.corFraca,
            ),
            title: Text(
              'Adiconar atalhos',
              style: TextStyle(
                color: tema.pretoEBrancoColor,
              ),
            ),
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: ListTile(
            leading: SizedBox(
              height: 35,
              child: Image.asset("assets/icons/person_favorite_icon.png",
                  color: tema.corFraca),
            ),
            title: Text(
              'Adicionar Favoritos a Tela Principal',
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  IconesNaTela(iconesVisiveis: iconesVisiveissalvos),
            ),
          );
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AmigosPage(
                userId: _auth.currentUser!.uid,
                addGrupo: false,
                exibirFavoritos: true,
              ),
            ),
          );
          break;

        default:
      }
    }
  }
}
