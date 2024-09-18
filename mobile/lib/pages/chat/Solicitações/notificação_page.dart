// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/autenticando_servico.dart';

class SolicitacoesDeAmizade extends StatefulWidget {
  const SolicitacoesDeAmizade({Key? key}) : super(key: key);

  @override
  _SolicitacoesDeAmizadeState createState() => _SolicitacoesDeAmizadeState();
}

class _SolicitacoesDeAmizadeState extends State<SolicitacoesDeAmizade> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService auntenticando = AuthService();
  late TemaDoApp tema;

  @override
  void initState() {
    tema = Provider.of<TemaDoApp>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tema.backgroundColor,
      appBar: AppBar(
        backgroundColor: tema.cabecarioColor,
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
          'Convites e Pedidos de Amizade',
          style: TextStyle(color: tema.pretoEBrancoColor),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Solicitações de Amizade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tema.pretoEBrancoColor,
              ),
            ),
          ),
          _buildFriendRequests(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Convites para Grupos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tema.pretoEBrancoColor,
              ),
            ),
          ),
          _buildGroupInvites(),
        ],
      ),
    );
  }

  Widget _buildFriendRequests() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _getFriendRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma solicitação de amizade.',
                style: TextStyle(color: tema.corFraca),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar solicitações de amizade.',
                style: TextStyle(color: tema.corFraca),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final request = snapshot.data!.docs[index];
                return _buildFriendRequestItem(request);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildGroupInvites() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _getGroupInvitesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nenhum convite para grupo.',
                style: TextStyle(color: tema.corFraca),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar convites para grupos.',
                style: TextStyle(color: tema.corFraca),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final invite = snapshot.data!.docs[index];
                return _buildGroupInviteItem(invite);
              },
            );
          }
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getFriendRequestsStream() {
    final currentUserUid = _auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection("Usuario")
        .doc(currentUserUid)
        .collection("solicitacoes_amizade")
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot> _getGroupInvitesStream() {
    final currentUserUid = _auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection("Usuario")
        .doc(currentUserUid)
        .collection("convites")
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Widget _buildFriendRequestItem(DocumentSnapshot request) {
    final requestData = request.data() as Map<String, dynamic>;
    final senderUid = requestData['senderUid'];
    final timestamp = requestData['timestamp'];

    return ListTile(
      title: FutureBuilder<String>(
        future: _getUserApelido(senderUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return  Text(
              'Erro ao carregar nome do remetente.',
              style: TextStyle(color: tema.pretoEBrancoColor),
            );
          } else {
            return Text(
              'Solicitação de Amizade de ${snapshot.data}',
              style:  TextStyle(color: tema.pretoEBrancoColor),
            );
          }
        },
      ),
      subtitle: Text(
        'Enviado em: ${_formatTimestamp(timestamp)}',
        style:  TextStyle(color: tema.pretoEBrancoColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              auntenticando.aceitarSolicitacaoAmizade(request.id);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tema.cabecarioColor,
            ),
            child: const Text(
              'Aceitar',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              auntenticando.rejeitarSolicitacaoAmizade(request.id);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tema.cabecarioColor,
            ),
            child: const Text(
              'Rejeitar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInviteItem(DocumentSnapshot invite) {
    final inviteData = invite.data() as Map<String, dynamic>;
    final groupId = inviteData['groupId'];
    final nomeDoGrupo = inviteData['nomeDoGrupo'];

    final timestamp = inviteData['timestamp'];

    return ListTile(
      title: Text(
        'Convite para o Grupo $nomeDoGrupo',
        style:  TextStyle(color: tema.pretoEBrancoColor),
      ),
      subtitle: Text(
        'Enviado em: ${_formatTimestamp(timestamp)}',
        style:  TextStyle(color:  tema.pretoEBrancoColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              auntenticando.aceitarConvite(groupId);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tema.cabecarioColor,
            ),
            child: const Text(
              'Aceitar',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              auntenticando.rejeitarConvite(groupId);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tema.cabecarioColor,
            ),
            child: const Text(
              'Rejeitar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getUserApelido(String uid) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection("Usuario").doc(uid).get();
    return userSnapshot.get("username");
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
