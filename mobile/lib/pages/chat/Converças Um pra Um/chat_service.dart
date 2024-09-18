// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_hub_vs2/model/massage.dart';

class ChatService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> enviarMessage(String receiverID, String message, ) async {
    try {
      final String currentUserId = _firebaseAuth.currentUser!.uid;
      final String currentUserEmail =
          _firebaseAuth.currentUser!.email.toString();
      final Timestamp timestamp = Timestamp.now();

      Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverID,
        message: message,
        timestamp: timestamp, isVideo: '',
         
      );

      List<String> ids = [currentUserId, receiverID];
      ids.sort();
      String chatRoomId = ids.join("_");

      await _atulizarVisibilityParaTrue(currentUserId, receiverID);

      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print("Erro ao enviar mensagem: $e");
    }
  }

  Future<void> _atulizarVisibilityParaTrue(
      String senderId, String receiverId) async {
    try {
      await _firestore
          .collection("amigos")
          .doc(receiverId)
          .collection('lista')
          .doc(senderId)
          .update({'visibility': true});
    } catch (e) {
      print("Erro ao atualizar a visibilidade: $e");
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    try {
      List<String> ids = [userId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");

      return _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("timestamp", descending: false)
          .snapshots();
    } catch (e) {
      print("Erro ao obter mensagens: $e");
      rethrow;
    }
  }

  Future<UserInfo> getUserInfo(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection("Usuario").doc(userId).get();

      if (userSnapshot.exists) {
        UserInfo userInfo = UserInfo(
          userId: userId,
          username: userSnapshot.get("username"),
          email: userSnapshot.get("email"),
        );

        return userInfo;
      } else {
        throw Exception("Usuário não encontrado");
      }
    } catch (e) {
      throw Exception("Erro ao obter informações do usuário: $e");
    }
  }

  Future<void> enviarImage(
      String receiverID, String imageUrl, String message, isVideo) async {
    try {
      final String currentUserId = _firebaseAuth.currentUser!.uid;
      final String currentUserEmail =
          _firebaseAuth.currentUser!.email.toString();
      final Timestamp timestamp = Timestamp.now();

      Message newImageMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverID,
        message: message,
        imageUrl: imageUrl,
        timestamp: timestamp,
        isVideo: isVideo,
      );

      List<String> ids = [currentUserId, receiverID];
      ids.sort();
      String chatRoomId = ids.join("_");

      await _atulizarVisibilityParaTrue(currentUserId, receiverID);

      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .add(newImageMessage.toMap());
    } catch (e) {
      print("Erro ao enviar imagem: $e");
    }
  }

  // Future<void> _atulizarVisibilityDOGrupoParaTrue(
  //     String groupId, String senderId, String receiverId) async {
  //   try {
  //     await _firestore
  //         .collection("chat_rooms_group")
  //         .doc(groupId)
  //         .collection('lista')
  //         .doc(senderId)
  //         .update({'visibility': true});
  //   } catch (e) {
  //     print("Erro ao atualizar a visibilidade: $e");
  //   }
  // }

  Future<void> enviarMenssageGrupo(
    String groupId,
    String message,
    
  ) async {
    try {
      final String currentUserId = _firebaseAuth.currentUser!.uid;
      final String currentUserEmail =
          _firebaseAuth.currentUser!.email.toString();
      final Timestamp timestamp = Timestamp.now();

      Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: groupId,
        message: message,
        timestamp: timestamp,
        isVideo: "",
      );
      await _atulizarVisibilityParaTrue(currentUserId, groupId);
      await _firestore
          .collection("group_chat")
          .doc(groupId)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Stream<QuerySnapshot> getGroupMessages(String groupId) {
    return _firestore
        .collection("group_chat")
        .doc(groupId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> sendImage(
    String groupId,
    String imageUrl,
    String message,
    isVideo,
  ) async {
    try {
      final String currentUserId = _firebaseAuth.currentUser!.uid;
      final String currentUserEmail =
          _firebaseAuth.currentUser!.email.toString();
      final Timestamp timestamp = Timestamp.now();

      Message newImageMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: groupId,
        message: message,
        imageUrl: imageUrl,
        timestamp: timestamp,
        isVideo: isVideo,
      );

      await _firestore
          .collection("group_chat")
          .doc(groupId)
          .collection("messages")
          .add(newImageMessage.toMap());
    } catch (e) {
      print("Error sending image: $e");
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}

class UserInfo {
  final String userId;
  final String username;
  final String email;

  UserInfo({
    required this.userId,
    required this.username,
    required this.email,
  });
}
