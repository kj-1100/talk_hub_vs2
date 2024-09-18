// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AmigosEGrupoService extends ChangeNotifier {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
////////////////USUARIO
  Future<List<String>> pegarInformacaoDoAmigo(String friendUid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("Usuario")
          .doc(friendUid)
          .get();

      if (userSnapshot.exists) {
        String username =
            userSnapshot.get("username") ?? "Nome de usuário indisponível";
        String fotoPerfilUrl = userSnapshot.get("fotoPerfilUrl") ??
            "URL da imagem de perfil indisponível";

        return [
          username,
          fotoPerfilUrl,
        ];
      } else {
        return ["Usuário não encontrado", ""];
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> apagarAmigo(String friendUid, userId) async {
    await _apagarMensagens(userId, friendUid);

    await _firestore
        .collection("Usuario")
        .doc(userId)
        .collection('amigos')
        .doc(friendUid)
        .update({'visibility': false});
  }

  Future<void> _apagarMensagens(String fromUserId, String userId) async {
    await _firestore
        .collection('mensagens')
        .doc(fromUserId)
        .collection('conversas')
        .doc(userId)
        .delete();
  }

  Future<void> blockAmigo(String friendUid, String userId) async {
    await _firestore
        .collection("Usuario")
        .doc(userId)
        .collection('amigos')
        .doc(friendUid)
        .delete();
  }
}