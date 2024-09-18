// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
////////////////USUARIO
  Future<UserCredential> logandoSenhaEmail(String email, String senha) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await _firestore.collection("Usuario").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> atualizarFotoPerfil(String fotoPerfilUrl) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("Usuario")
          .doc(userId)
          .update({
        "fotoPerfilUrl": fotoPerfilUrl,
      });
    } catch (e) {
      throw Exception("Erro ao atualizar a foto de perfil: $e");
    }
  }

  Future<void> atualizarApelido(String novoApelido) async {
    try {
      print(novoApelido);
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection("Usuario")
          .doc(userId)
          .update({
        "username": novoApelido,
      });
    } catch (e) {
      throw Exception("Erro ao atualizar a foto de perfil: $e");
    }
  }

  Future<UserCredential> criandoContaEmailSenha(String email, String senha,
      String username, String? fotoPerfilUrl) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      fotoPerfilUrl ??= "";

      await _firestore.collection("Usuario").doc(userCredential.user!.uid).set(
        {
          "senha": senha,
          "uid": userCredential.user!.uid,
          "email": email,
          "username": username,
          "fotoPerfilUrl": fotoPerfilUrl,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(e);
      throw Exception(e.code);
    }
  }

  Future<void> sairConta() async {
    return await FirebaseAuth.instance.signOut();
  }

////////////////SOLICITAÇÃO AMIZADE
  Future<void> enviarSolicitacaoAmizade(String friendUid) async {
    try {
      // Obtendo o usuário atualmente autenticado
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser != null) {
        // Acessando o apelido (displayName) e o email do usuário atual
        final meuApelido = currentUser.displayName;
        final meuEmail = currentUser.email;

        // Adicionando a solicitação de amizade ao Firestore
        await FirebaseFirestore.instance
            .collection("Usuario")
            .doc(friendUid)
            .collection("solicitacoes_amizade")
            .add({
          'email': meuEmail,
          'username': meuApelido,
          'senderUid': currentUser.uid,
          'receiverUid': friendUid,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
      } else {
        throw Exception("Usuário não autenticado.");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> aceitarSolicitacaoAmizade(String solicitacaoId) async {
    try {
      DocumentSnapshot solicitacaoSnapshot = await _firestore
          .collection("Usuario")
          .doc(_firebaseAuth.currentUser!.uid)
          .collection("solicitacoes_amizade")
          .doc(solicitacaoId)
          .get();

      String senderUid = solicitacaoSnapshot.get('senderUid');
      String receiverUid = solicitacaoSnapshot.get('receiverUid');

      await _firestore
          .collection("Usuario")
          .doc(_firebaseAuth.currentUser!.uid)
          .collection("solicitacoes_amizade")
          .doc(solicitacaoId)
          .update({'status': 'accepted'});

      await _adicionarAmigoNaListaDeAmigos(senderUid, receiverUid);
      await _adicionarAmigoNaListaDeAmigos(receiverUid, senderUid);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _adicionarAmigoNaListaDeAmigos(
      String userUid, String friendUid) async {
    await _firestore
        .collection("Usuario")
        .doc(userUid)
        .collection("amigos")
        .doc(friendUid)
        .set({
      'friendUid': friendUid,
      'timestamp': FieldValue.serverTimestamp(),
      "visibility": true,
    }, SetOptions(merge: true));
  }

  Future<void> rejeitarSolicitacaoAmizade(String solicitacaoId) async {
    try {
      await _firestore
          .collection("Usuario")
          .doc(_firebaseAuth.currentUser!.uid)
          .collection("solicitacoes_amizade")
          .doc(solicitacaoId)
          .update({'status': 'rejected'});
    } catch (e) {
      throw Exception(e);
    }
  }

////////////////CONVITE GRUPO
  // Método para enviar convites
  Future<void> enviarConvite(
      String destinatarioUid, String nomeDoGrupo, String groupId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser != null) {
        final meuApelido = currentUser.displayName;
        final meuEmail = currentUser.email;
        final remetenteUid = currentUser.uid;

        await _firestore
            .collection("Usuario")
            .doc(destinatarioUid)
            .collection("convites")
            .add({
          'email': meuEmail,
          'username': meuApelido,
          'remetenteUid': remetenteUid,
          'destinatarioUid': destinatarioUid,
          'nomeDoGrupo': nomeDoGrupo,
          'groupId': groupId,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception("Erro ao enviar convite: $e");
    }
  }

  // Método para aceitar convite
  Future<void> aceitarConvite(String groupId) async {
    try {
      final usuarioLogadoUid = _firebaseAuth.currentUser!.uid;
      final groupInviteRef = await _firestore
          .collection("Usuario")
          .doc(usuarioLogadoUid)
          .collection("convites")
          .where('groupId', isEqualTo: groupId)
          .get(); // Obtém o convite correspondente ao groupId

      if (groupInviteRef.docs.isNotEmpty) {
        // Atualiza o status do convite para aceito
        await groupInviteRef.docs.first.reference.update({
          'status': 'accepted',
        });

        // Adiciona o usuário ao grupo
        await _firestore.collection("grupos").doc(groupId).update({
          'members.$usuarioLogadoUid': true,
        });
      }
    } catch (e) {
      throw Exception("Erro ao aceitar convite para o grupo: $e");
    }
  }
  // Método para rejeitar convite
  Future<void> rejeitarConvite(String groupId) async {
    try {
      final usuarioLogadoUid = _firebaseAuth.currentUser!.uid;
      await _firestore
          .collection("Usuario")
          .doc(usuarioLogadoUid)
          .collection("convites")
          .where('groupId', isEqualTo: groupId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete(); // Exclui o convite correspondente ao groupId
        }
      });
    } catch (e) {
      throw Exception("Erro ao rejeitar convite para o grupo: $e");
    }
  }

///////////////PEGAR ITENS
  Future<String> getUserEmail(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection("Usuario").doc(uid).get();

      if (userSnapshot.exists) {
        return userSnapshot.get("email");
      } else {
        return "Usuário não encontrado";
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> getUserApelido(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection("Usuario").doc(uid).get();
      if (userSnapshot.exists) {
        return userSnapshot.get("username") ?? "Apelido Indisponível";
      } else {
        return "Apelido Indisponível";
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<String>> getUserInfo(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection("Usuario").doc(uid).get();
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

      String apelido = userData["username"];
      String email = userData["email"];
      String fotoPerfilUrl = userData["email"];
      return [apelido, email, fotoPerfilUrl];
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String?> getFotoPerfilUrl(String uid) async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection("Usuario").doc(uid).get();

      if (userSnapshot.exists) {
        String fotoPerfilUrl = userSnapshot.get("fotoPerfilUrl");
        return fotoPerfilUrl;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> verificarAmizade(String friendUid) async {
    try {
      // Obtendo o usuário atualmente autenticado
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser != null) {
        // Verificando se o usuário é amigo do usuário fornecido
        final friendSnapshot = await _firestore
            .collection("Usuario")
            .doc(currentUser.uid)
            .collection("amigos")
            .doc(friendUid)
            .get();

        return friendSnapshot.exists;
      } else {
        throw Exception("Usuário não autenticado.");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
