// ignore_for_file: use_build_context_synchronously, no_logic_in_create_state, unused_field, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';
import 'package:talk_hub_vs2/pages/chat/Conver%C3%A7as%20Um%20pra%20Um/pagina_convera.dart';
import 'package:talk_hub_vs2/pages/chat/paradinha_do_chat.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/autenticando_servico.dart';

class AmigosPage extends StatefulWidget {
  final String userId;
  final bool addGrupo;
  final String? groupId;
  final String? nomeDoGrupo;
  final bool? exibirFavoritos;

  const AmigosPage(
      {Key? key,
      required this.userId,
      required this.addGrupo,
      this.groupId,
      this.nomeDoGrupo,
      this.exibirFavoritos})
      : super(key: key);

  @override
  State<AmigosPage> createState() => AmigosPageState(
        userId: userId,
        addGrupo: addGrupo,
        groupId: groupId,
        nomeDoGrup: nomeDoGrupo,
      );
}

class AmigosPageState extends State<AmigosPage> {
  TextEditingController apelidoController = TextEditingController();
  final Map<String, bool> _usuariosSelecionados = {};
  List<DocumentSnapshot> _resultadosPesquisa = [];
  final AuthService authService = AuthService();
  late AmigosEGrupoService amigoEgrupoService;
  List<String> favoritosList = [];
  bool _bloquearAmigos = false;
  bool _oCheckAparece = false;
  late bool _exibirFavoritos;
  bool _apagarAmigos = false;
  bool _pesquisando = false;
  final String? nomeDoGrup;
  final String? groupId;
  int oqueVaiFazer = 0;
  final bool addGrupo;
  final String userId;
  late TemaDoApp tema;
  int foi = 0;

  AmigosPageState({
    Key? key,
    required this.userId,
    required this.addGrupo,
    this.groupId,
    this.nomeDoGrup,
  });

  @override
  void initState() {
    tema = Provider.of<TemaDoApp>(context, listen: false);
    amigoEgrupoService =
        Provider.of<AmigosEGrupoService>(context, listen: false);
    tema.recuperarFavoritosLocalmente();
    _exibirFavoritos=widget.exibirFavoritos??false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tema.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Amigos',
          style: TextStyle(color: tema.pretoEBrancoColor),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const InicialPage(recarregar: true)),
            );
          },
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
      ),
      body: _buildAmigosList(),
      floatingActionButton: _usuariosSelecionados.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                switch (oqueVaiFazer) {
                  case 1:
                    _apagarUsuariosSelecionados();

                    foi = 1;
                    break;
                  case 2:
                    _bloquearUsuariosSelecionados();

                    break;
                  default:
                }
              },
              backgroundColor: tema.cabecarioColor,
              child: Icon(
                oqueVaiFazer == 1 ? Icons.delete_outline : Icons.block_outlined,
                color: tema.corFraca,
                size: 35,
              ),
            )
          : null,
    );
  }

  //WIDGETS
  Widget _buildAmigoItem(DocumentSnapshot document) {
    String friendUid = document['friendUid'];

    return GestureDetector(
      onTap: () async {
        if (_bloquearAmigos != null && _bloquearAmigos) {
          _toggleBloquearAmigos(friendUid);
        }
        if (_apagarAmigos != null && _apagarAmigos) {
          _toggleApagarAmigos(friendUid);
        } else {
          List<dynamic> userData =
              await amigoEgrupoService.pegarInformacaoDoAmigo(friendUid);
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
        }
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                marcar(friendUid),
                FutureBuilder(
                  future: amigoEgrupoService.pegarInformacaoDoAmigo(friendUid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<dynamic> userData = snapshot.data as List<dynamic>;
                      String userName = userData[0];
                      String fotoPerfilUrl = userData[1];

                      return Row(
                        children: [
                          InkWell(
                            onTap: () {
                              _mostrarImagemExpandida(fotoPerfilUrl);
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(fotoPerfilUrl),
                              radius: 31.5,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            userName,
                            style: TextStyle(
                                color: tema.pretoEBrancoColor, fontSize: 23),
                          ),
                        ],
                      );
                    } else {
                      return const Text('Carregando...');
                    }
                  },
                ),
              ],
            ),
            _exibirFavoritos
                ? GestureDetector(
                    onTap: () async {
                      await _addFavoritos(friendUid);
                    },
                    child: tema.favoritos.contains(friendUid)
                        ? const Icon(Icons.star,
                            size: 40) // Se estiver na lista de favoritos
                        : const Icon(Icons.star_border,
                            size: 40), // Se não estiver na lista de favoritos
                  )
                : const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAmigoGrupoItem(DocumentSnapshot document) {
    String friendUid = document['friendUid'];

    return GestureDetector(
      onTap: () async {
        List<String>? userInfo =
            await amigoEgrupoService.pegarInformacaoDoAmigo(friendUid);
        if (userInfo != null && userInfo.length >= 2) {
          String userName = userInfo[0];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaginaConvera(
                resiveruserEmail: 'email_do_seu_amigo',
                resiverUserID: friendUid,
                resiverApelido: userName,
              ),
            ),
          );
        }
      },
      child: ListTile(
        trailing: IconButton(
          onPressed: () async {
            await authService.enviarConvite(friendUid, nomeDoGrup!, groupId!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Convite Enviado'),
                backgroundColor: Colors.blueAccent,
              ),
            );
          },
          icon: const Icon(
            Icons.person_add_outlined,
            size: 33,
          ),
        ),
        title: Row(
          children: [
            marcar(friendUid),
            FutureBuilder(
              future: amigoEgrupoService.pegarInformacaoDoAmigo(friendUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<dynamic>? userData = snapshot.data as List<dynamic>?;
                  if (userData != null && userData.length >= 2) {
                    String userName = userData[0];
                    String fotoPerfilUrl = userData[1];

                    return Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(fotoPerfilUrl),
                          radius: 31.5,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          userName,
                          style: TextStyle(
                              color: tema.pretoEBrancoColor, fontSize: 23),
                        ),
                      ],
                    );
                  } else {
                    return const Text('Dados inválidos');
                  }
                } else {
                  return const Text('Carregando...');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmigosList() {
    return _pesquisando
        ? _buildResultadoPesquisa()
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Usuario")
                .doc(userId)
                .collection('amigos')
                .where('visibility', isEqualTo: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Erro ao carregar amigos');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final amigosSolicitacoes = snapshot.data!.docs;

              if (addGrupo == false) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        key: UniqueKey(),
                        children: amigosSolicitacoes
                            .map<Widget>((doc) => _buildAmigoItem(doc))
                            .toList(),
                      ),
                    ),
                  ],
                );
              } else if (addGrupo == true) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        key: UniqueKey(),
                        children: amigosSolicitacoes
                            .map<Widget>((doc) => _buildAddAmigoGrupoItem(doc))
                            .toList(),
                      ),
                    ),
                  ],
                );
              }
              // Adicione um retorno padrão caso 'addGrupo' não seja nem true nem false
              return Container();
            },
          );
  }

  Widget marcar(String friendUid) {
    if (_oCheckAparece == true) {
      return Checkbox(
        activeColor: Colors.blueAccent,
        value: _usuariosSelecionados[friendUid] ?? false,
        onChanged: (value) {
          setState(() {
            _usuariosSelecionados[friendUid] = value!;
          });
        },
      );
    } else {
      return Container();
    }
  }

  Widget _buildResultadoPesquisa() {
    return _resultadosPesquisa.isNotEmpty
        ? ListView(
            key: UniqueKey(),
            children: _resultadosPesquisa
                .map<Widget>((doc) => _buildAmigoItem(doc))
                .toList(),
          )
        : Center(
            child: Text(
              'Nenhum resultado encontrado',
              style: TextStyle(color: tema.pretoEBrancoColor),
            ),
          );
  }

//VOIDS

  //PESQUISA
  void _realizarPesquisa(String apelido) {
    FirebaseFirestore.instance
        .collection("Usuario")
        .where("username", isEqualTo: apelido)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String uidEncontrado = querySnapshot.docs.first.id;
        _buscarAmigosLista(uidEncontrado);
      } else {
        setState(() {
          _resultadosPesquisa = [];
          _pesquisando = true;
        });
      }
    }).catchError(
      (error) {
        setState(
          () {
            _resultadosPesquisa = [];
            _pesquisando = true;
          },
        );
      },
    );
  }

  void _buscarAmigosLista(String uid) {
    FirebaseFirestore.instance
        .collection("Usuario")
        .doc(userId)
        .collection('amigos')
        .doc(uid)
        .get()
        .then(
      (DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            _resultadosPesquisa = [documentSnapshot];
            _pesquisando = true;
          });
        } else {
          setState(() {
            _resultadosPesquisa = [];
            _pesquisando = true;
          });
        }
      },
    ).catchError(
      (error) {
        setState(
          () {
            _resultadosPesquisa = [];
            _pesquisando = true;
          },
        );
      },
    );
  }

  //Block
  void _bloquearUsuariosSelecionados() async {
    List<String> usuariosSelecionados = [];

    _usuariosSelecionados.forEach((key, value) {
      if (value) {
        usuariosSelecionados.add(key);
      }
    });

    for (String uid in usuariosSelecionados) {
      await amigoEgrupoService.blockAmigo(uid, userId);
    }

    setState(() {
      _usuariosSelecionados.clear();
      _bloquearAmigos = false;
      _oCheckAparece = false;
    });
  }

  void _toggleBloquearAmigos(String friendUid) {
    setState(() {
      _usuariosSelecionados[friendUid] = !_usuariosSelecionados[friendUid]!;
    });
  }

  //Apagar
  void _apagarUsuariosSelecionados() async {
    List<String> usuariosSelecionados = [];

    _usuariosSelecionados.forEach((key, value) {
      if (value) {
        usuariosSelecionados.add(key);
      }
    });

    if (usuariosSelecionados.isNotEmpty) {
      for (String uid in usuariosSelecionados) {
        await amigoEgrupoService.apagarAmigo(uid, userId);
      }

      setState(() {
        _usuariosSelecionados.clear();
        _apagarAmigos = false;
        _oCheckAparece = false;
      });
    } else {}
  }

  void _toggleApagarAmigos(String friendUid) {
    setState(() {
      _usuariosSelecionados[friendUid] = !_usuariosSelecionados[friendUid]!;
    });
  }

  //FIREBASE INTERAÇÃO
  Future<void> _addFavoritos(String friendUid) async {
    if (favoritosList.contains(friendUid)) {
      favoritosList.remove(friendUid);
      await FirebaseFirestore.instance
          .collection("Usuario")
          .doc(userId)
          .collection('amigos')
          .doc(friendUid)
          .update(
        {
          "favorito": false // Alterne o estado favoritado individual
        },
      );
      setState(() {});
      tema.salvarFavoritosLocalmente(favoritosList);
      tema.recuperarFavoritosLocalmente();
    } else {
      favoritosList.add(friendUid);
      await FirebaseFirestore.instance
          .collection("Usuario")
          .doc(userId)
          .collection('amigos')
          .doc(friendUid)
          .update(
        {
          "favorito": true // Alterne o estado favoritado individual
        },
      );
      tema.salvarFavoritosLocalmente(favoritosList);
      tema.recuperarFavoritosLocalmente();
      setState(() {});
    }
  }

  // FUNÇÕES COMPLEXAS

  void _mostrarImagemExpandida(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pop(); // Fechar o dialog ao tocar fora da imagem
            },
            child: SizedBox(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
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
              Icons.search_outlined,
              color: tema.corFraca,
            ),
            title: Text(
              'Buscar',
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
              Icons.person_remove_outlined,
              color: tema.corFraca,
            ),
            title: Text(
              'Apagar',
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
              Icons.person_off_outlined,
              color: tema.corFraca,
            ),
            title: Text(
              'Apagar e bloquear',
              style: TextStyle(
                color: tema.pretoEBrancoColor,
              ),
            ),
          ),
        ),
        PopupMenuItem<int>(
          value: 4,
          child: ListTile(
            leading: Icon(
              Icons.star,
              color: tema.corFraca,
            ),
            title: Text(
              'Adicionar a tela inicial',
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
          _pesquisarUsuarios(context);
          break;
        case 2:
          setState(() {
            _oCheckAparece = true;
            _apagarAmigos = true;
            oqueVaiFazer = 1;
          });
          break;
        case 3:
          setState(() {
            _bloquearAmigos = true;
            _oCheckAparece = true;
            oqueVaiFazer = 2;
          });

          break;
        case 4:
          setState(() {
            _exibirFavoritos = !_exibirFavoritos;
          });

          break;
        default:
      }
    }
  }

  void _pesquisarUsuarios(BuildContext context) {
    _resultadosPesquisa = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tema.popUplColor,
          title: Text(
            "Pesquisar Usuário",
            style: TextStyle(color: tema.pretoEBrancoColor),
          ),
          content: TextField(
            controller: apelidoController,
            style: TextStyle(color: tema.pretoEBrancoColor),
            decoration: InputDecoration(
              hintText: "Digite o apelido do usuário",
              hintStyle: TextStyle(color: tema.corFraca),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
            ),
            cursorColor: Colors.blueAccent,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _realizarPesquisa(apelidoController.text);
              },
              child: const Text(
                "Pesquisar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
