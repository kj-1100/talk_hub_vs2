// ignore_for_file: unrelated_type_equality_checks, unused_field, use_build_context_synchronously, library_private_types_in_public_api, avoid_function_literals_in_foreach_calls, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';
import 'package:talk_hub_vs2/pages/chat/Solicita%C3%A7%C3%B5es/notifica%C3%A7%C3%A3o_page.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/autenticando_servico.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _resultadosPesquisa = [];
  final AuthService _authService = AuthService();
  bool _pesquisando = false;
  late TemaDoApp tema;

  @override
  void initState() {
    tema = Provider.of<TemaDoApp>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: tema.backgroundColor,
        appBar: AppBar(
          backgroundColor: tema.cabecarioColor,
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: tema.pretoEBrancoColor,
              ),
              onPressed: () {
                _pesquisarUsuarios(context);
              },
            ),
          ],
          leading: IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_left_outlined,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              if (_pesquisando) {
                setState(() {
                  _pesquisando = false;
                  _resultadosPesquisa = [];
                });
              } else {
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InicialPage(),
                  ),
                );
              }
            },
          ),
          title: Center(
            child: Text(
              "Usuarios",
              style: TextStyle(color: tema.pretoEBrancoColor),
            ),
          ),
        ),
        body: FutureBuilder<Widget>(
          future: _buildListaUsuarios(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ),
              );
            } else if (snapshot.hasError) {
              return const Text("Erro ao carregar usuários");
            } else {
              return snapshot.data ?? Container();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SolicitacoesDeAmizade(),
              ),
            );
          },
          tooltip: 'Solicitações de Amizade',
          backgroundColor: tema.cabecarioColor,
          child: Icon(
            Icons.notifications_outlined,
            color: tema.corFraca,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data["email"]) {
      return Container(
        padding: const EdgeInsets.all(1),
        child: ListTile(
          title: Text(
            data["username"],
            style: TextStyle(color: tema.pretoEBrancoColor),
          ),
          trailing: FutureBuilder<bool>(
            future: _verificarSolicitacaoOuAmizade(data["uid"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent,
                    strokeWidth: 2.0,
                  ),
                );
              } else if (snapshot.hasError) {
                return const Icon(Icons.error, color: Colors.red);
              } else if (snapshot.data!) {
                return ElevatedButton(
                  onPressed: () async {
                    await _cancelarSolicitacaoAmizade(data["uid"]);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tema.cabecarioColor,
                  ),
                  child: const Icon(Icons.cancel, color: Colors.red),
                );
              } else {
                return FutureBuilder<bool>(
                  future: _authService.verificarAmizade(data["uid"]),
                  builder: (context, snapshotAmizade) {
                    if (snapshotAmizade.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                          strokeWidth: 2.0,
                        ),
                      );
                    } else if (snapshotAmizade.hasError) {
                      return const Icon(Icons.error, color: Colors.red);
                    } else if (snapshotAmizade.data!) {
                      return ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tema.cabecarioColor,
                        ),
                        child: Text(
                          "Já são amigos",
                          style: TextStyle(
                            color: tema.pretoEBrancoColor,
                          ),
                        ),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () async {
                          bool jaEnviouSolicitacao =
                              await _verificarSolicitacaoOuAmizade(data["uid"]);

                          if (!jaEnviouSolicitacao) {
                            await _authService
                                .enviarSolicitacaoAmizade(data["uid"]);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Solicitação de amizade enviada'),
                              ),
                            );
                            setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Você já enviou uma solicitação para esse usuário'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tema.cabecarioColor,
                        ),
                        child: const Icon(Icons.person_add_outlined,
                            color: Colors.blueAccent),
                      );
                    }
                  },
                );
              }
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<Widget> _buildListaUsuarios() async {
    return _resultadosPesquisa.isNotEmpty
        ? ListView(
            key: UniqueKey(),
            children: _resultadosPesquisa
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          )
        : StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("Usuario").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("erro");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent,
                  ),
                );
              }

              return FutureBuilder<List<DocumentSnapshot>>(
                future: _ordenarUsuarios(snapshot.data!.docs),
                builder: (context, snapshotUsuarios) {
                  if (snapshotUsuarios.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    );
                  }

                  if (snapshotUsuarios.hasError) {
                    return const Text("Erro ao carregar usuários");
                  }

                  List<DocumentSnapshot> usuarios = snapshotUsuarios.data!;
                  return ListView(
                    key: UniqueKey(),
                    children: usuarios
                        .map<Widget>((doc) => _buildUserListItem(doc))
                        .toList(),
                  );
                },
              );
            },
          );
  }

  Future<List<DocumentSnapshot>> _ordenarUsuarios(
      List<DocumentSnapshot> usuarios) async {
    List<DocumentSnapshot> comSolicitacao = [];
    List<DocumentSnapshot> semSolicitacao = [];

    for (var usuario in usuarios) {
      bool jaEnviouSolicitacao =
          await _verificarSolicitacaoOuAmizade(usuario["uid"]);

      if (jaEnviouSolicitacao) {
        comSolicitacao.add(usuario);
      } else {
        semSolicitacao.add(usuario);
      }
    }

    return [...comSolicitacao, ...semSolicitacao];
  }

  void _pesquisarUsuarios(BuildContext context) {
    setState(() {
      _resultadosPesquisa = [];
      _pesquisando = true;
    });

    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tema.popUplColor,
          title: Text(
            "Pesquisar Usuário",
            style: TextStyle(
              color: tema.pretoEBrancoColor,
            ),
          ),
          content: TextField(
            controller: emailController,
            style: TextStyle(color: tema.pretoEBrancoColor),
            decoration: InputDecoration(
              hintText: "Digite o email do usuário",
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
                _realizarPesquisa(emailController.text);
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

  void _realizarPesquisa(String email) {
    FirebaseFirestore.instance
        .collection("Usuario")
        .where("email", isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<DocumentSnapshot> resultados = querySnapshot.docs;

      setState(() {
        _resultadosPesquisa = resultados;
      });
    }).catchError((error) {
      //print("Erro na pesquisa: $error");
    });
  }

  Future<void> _realizarCancelamento(String friendUid) async {
    try {
      FirebaseFirestore.instance
          .collection("Usuario")
          .doc(friendUid)
          .collection("solicitacoes_amizade")
          .where('senderUid', isEqualTo: _auth.currentUser!.uid)
          .where('receiverUid', isEqualTo: friendUid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete().then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pedido de amizade cancelado.'),
              ),
            );
          });
        });
      });
    } catch (error) {
      print("Erro ao cancelar solicitação de amizade: $error");
    }
  }

  Future<bool> _verificarSolicitacaoOuAmizade(String friendUid) async {
    try {
      QuerySnapshot solicitacoesPendentes = await FirebaseFirestore.instance
          .collection("Usuario")
          .doc(friendUid)
          .collection("solicitacoes_amizade")
          .where('senderUid', isEqualTo: _auth.currentUser!.uid)
          .where('receiverUid', isEqualTo: friendUid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (solicitacoesPendentes.docs.isNotEmpty) {
        return true;
      }

      DocumentSnapshot amizadeSnapshot = await FirebaseFirestore.instance
          .collection("amigos")
          .doc(_auth.currentUser!.uid)
          .collection('lista')
          .doc(friendUid)
          .get();

      return amizadeSnapshot.exists;
    } catch (error) {
      print("Erro ao verificar solicitação de amizade: $error");
      return false;
    }
  }

  Future<void> _cancelarSolicitacaoAmizade(String friendUid) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: tema.popUplColor,
            title: Text(
              "Deseja cancelar o pedido de amizade?",
              style: TextStyle(color: tema.pretoEBrancoColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _realizarCancelamento(friendUid);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Confirmar",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 18),
                ),
              ),
            ],
          );
        },
      ).then((_) {
        setState(() {});
      });
    } catch (error) {
      print("Erro ao exibir diálogo de cancelamento: $error");
    }
  }
}
