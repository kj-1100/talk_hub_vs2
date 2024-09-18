import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;

  final String message;
  final String? imageUrl;
  final String isVideo;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.message,
    this.imageUrl,
    required this.isVideo,
    required this.timestamp,
    required String receiverId,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "senderEmail": senderEmail,
      "message": message,
      "imageUrl": imageUrl,
      "isVideo": isVideo,
      "timestamp": timestamp,
    };
  }
}
class GrupMessage {
  final String senderId;
  final String groupId;
  final String senderEmail;
  final String message;
  final String? imageUrl;
  final bool isVideo;
  final Timestamp timestamp;

  GrupMessage({
    required this.groupId,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    this.imageUrl,
    required this.isVideo,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "senderEmail": senderEmail,
      "message": message,
      "groupId": groupId,
      "imageUrl": imageUrl,
      "isVideo": isVideo,
      "timestamp": timestamp,
    };
  }
}


