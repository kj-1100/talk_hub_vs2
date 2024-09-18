// ignore_for_file: use_build_context_synchronously, no_logic_in_create_state, unused_field, unnecessary_null_comparison, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';
import 'package:talk_hub_vs2/pages/chat/grupos/criando_grupo.dart';
import 'package:talk_hub_vs2/pages/chat/grupos/pagina_conversa_grupo.dart';

class Grupos extends StatefulWidget {
  final String userId;

  const Grupos({Key? key, required this.userId}) : super(key: key);

  @override
  State<Grupos> createState() => _GruposState();
}

class _GruposState extends State<Grupos> {
  TextEditingController apelidoController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Map<String, bool> _usuariosSelecionados = {};
  List<DocumentSnapshot> _resultadosPesquisa = [];
  bool _bloquerAmigos = false;
  bool _checkaparece = false;
  bool _pesquisando = false;
  late TemaDoApp tema;
  int oqueVaiFazer = 1;

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
        backgroundColor: tema.cabecarioColor,
        title: Text(
          'Grupos',
          style: TextStyle(color: tema.pretoEBrancoColor),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => const InicialPage()),
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
      ),
      body: _buildGroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (oqueVaiFazer) {
            case 1:
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CriandoGrupo()),
                );
              }

              break;
            case 2:
              _sairDeletarGrupoSelecionado();
              break;
            default:
          }
        },
        backgroundColor: tema.botoesTelaInicialColor,
        child: Icon(
          oqueVaiFazer == 1 ? Icons.group_add_outlined : Icons.delete_outline,
          color: tema.corFraca,
          size: 35,
        ),
      ),
    );
  }

  // Método para construir um item de grupo
  Widget _buildGroupItem(DocumentSnapshot document) {
    String groupId = document.id; // ID do grupo

    return GestureDetector(
      onTap: () async {
        String groupName = await _getGroupName(groupId);
        String groupID = groupId;
        print("$groupID $groupName");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaginaConversaGrupo(
              groupId: groupID,
              groupName: groupName,
            ),
          ),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.all(5),
        title: Row(
          children: [
            marcarGrupo(groupId),
            FutureBuilder(
              future: _getGroupName(groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    children: [
                      const SizedBox(width: 5),
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(document['groupPhotoUrl'] ?? ''),
                        radius: 31.5,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        snapshot.data.toString(),
                        style: TextStyle(color: tema.pretoEBrancoColor),
                      )
                    ],
                  );
                } else {
                  return Text(
                    'Carregando...',
                    style: TextStyle(color: tema.pretoEBrancoColor),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Método para marcar grupos (não implementado)
  Widget marcarGrupo(String groupId) {
    if (_checkaparece == true) {
      return Checkbox(
        activeColor: Colors.blueAccent,
        value: _usuariosSelecionados[groupId] ?? false,
        onChanged: (value) {
          setState(() {
            _usuariosSelecionados[groupId] = value!;
          });
        },
      );
    } else {
      return Container();
    }
  }

  //retorna nome do grupo
  Future<String> _getGroupName(String groupId) async {
    final groupDoc = await FirebaseFirestore.instance
        .collection('grupos')
        .doc(groupId)
        .get();

    return groupDoc['groupName'] ?? '';
  }

  // Método para construir a lista de grupos
  Widget _buildGroupList() {
    final String userId = widget.userId;
    return _pesquisando
        ? _buildResultadoPesquisa()
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('grupos')
                .where('members.$userId',
                    isEqualTo: true) // Somente grupos em que o usuário é membro
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Erro ao carregar grupos');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final grupos = snapshot.data!.docs;

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      key: UniqueKey(),
                      children: grupos
                          .map<Widget>((doc) => _buildGroupItem(doc))
                          .toList(),
                    ),
                  ),
                ],
              );
            },
          );
  }

  // Método para construir o resultado da pesquisa
  Widget _buildResultadoPesquisa() {
    return _resultadosPesquisa.isNotEmpty
        ? ListView(
            key: UniqueKey(),
            children: _resultadosPesquisa
                .map<Widget>((doc) => _buildGroupItem(doc))
                .toList(),
          )
        : Center(
            child: Text(
              'Nenhum resultado encontrado',
              style: TextStyle(color: tema.pretoEBrancoColor),
            ),
          );
  }

  // Método para realizar uma pesquisa de grupo
  void _realizarPesquisa(String groupName) {
    FirebaseFirestore.instance
        .collection("grupos")
        .where("groupName", isEqualTo: groupName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String uidEncontrado = querySnapshot.docs.first.id;
        _buscarGrupoLista(uidEncontrado);
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

  // Método para buscar um grupo na lista
  void _buscarGrupoLista(String groupId) {
    FirebaseFirestore.instance.collection("grupos").doc(groupId).get().then(
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

  // Método para sair e deletar grupos selecionados
  void _sairDeletarGrupoSelecionado() async {
    List<String> gruposSelecionados = [];

    _usuariosSelecionados.forEach((key, value) {
      if (value) {
        gruposSelecionados.add(key);
      }
    });

    for (String groupId in gruposSelecionados) {
      await _sairDeGrupo(groupId);
      await _deletarGrupo(groupId);
    }
    setState(() {
      oqueVaiFazer = 1;
      _checkaparece = false;
    });
  }

  Future<void> _sairDeGrupo(String groupId) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        throw Exception('Usuário não está autenticado.');
      }

      DocumentSnapshot groupDoc =
          await _firestore.collection("grupos").doc(groupId).get();

      // if (!groupDoc.exists) {
      //   // O documento não existe, então não há necessidade de continuar
      //   print("O grupo com o ID $groupId não existe.");
      //   return;
      // }

      Map<String, dynamic> groupData =
          groupDoc.data() as Map<String, dynamic>? ?? {};

      bool isAdmin = groupData['adminUid'] == user.uid;

      if (isAdmin) {
        Map<String, dynamic> members =
            groupData['members'] as Map<String, dynamic>? ?? {};
        String oldestMemberId = members.keys.first;

        await _firestore.collection("grupos").doc(groupId).update({
          "adminUid": oldestMemberId,
        });

        await _firestore.collection("grupos").doc(groupId).update({
          "members.${user.uid}": FieldValue.delete(),
        });
      } else {
        await _firestore.collection("grupos").doc(groupId).update({
          "members.${user.uid}": FieldValue.delete(),
        });
      }

      await _firestore.collection("Usuario").doc(user.uid).update({
        "groups.$groupId": FieldValue.delete(),
      });
    } catch (e) {
      throw Exception("Erro ao sair do grupo: $e");
    }
  }

  Future<void> _deletarGrupo(String groupId) async {
    try {
      await _firestore.collection("grupos").doc(groupId).delete();
    } catch (e) {
      throw Exception("Erro ao deletar o grupo: $e");
    }
  }

  // Método para exibir o menu de contexto
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
              color: tema.setentaCorFraca,
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
              Icons.group_off_outlined,
              color: tema.setentaCorFraca,
            ),
            title: Text(
              'Apagar',
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
            _bloquerAmigos = true;
            _checkaparece = true;
            oqueVaiFazer = 2;
          });
          break;
        default:
      }
    }
  }

  // Método para pesquisar usuários
  void _pesquisarUsuarios(BuildContext context) {
    _resultadosPesquisa = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tema.popUplColor,
          title:  Text(
            "Pesquisar Usuário",
            style: TextStyle(color: tema.pretoEBrancoColor),
          ),
          content: TextField(
            controller: apelidoController,
            style:  TextStyle(color: tema.pretoEBrancoColor),
            decoration:  InputDecoration(
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
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _realizarPesquisa(apelidoController.text);
              },
              child: const Text(
                "Pesquisar",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
