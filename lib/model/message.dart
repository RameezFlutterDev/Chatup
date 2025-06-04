import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final bool isRead;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.isRead = false, // default to false for new messages
  });

  Map<String, dynamic> toMap() {
    return {
      "senderID": senderID,
      "senderEmail": senderEmail,
      "receiverID": receiverID,
      "message": message,
      "timestamp": timestamp,
      "isRead": isRead,
    };
  }

  // factory Message.fromMap(Map<String, dynamic> map) {
  //   return Message(
  //     senderID: map['senderID'],
  //     senderEmail: map['senderEmail'],
  //     receiverID: map['receiverID'],
  //     message: map['message'],
  //     timestamp: map['timestamp'],
  //     isRead: map['isRead'] ?? false,
  //   );
  // }
}
