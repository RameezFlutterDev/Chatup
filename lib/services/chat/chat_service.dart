import 'package:chatup/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  //get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        print(user);

        return user;
      }).toList();
    });
  }

  //send message
  Future<void> sendMessage(String recieverID, message) async {
    final String CurrentUserID = _auth.currentUser!.uid;
    final String CurrentUserEmail = _auth.currentUser!.email!;

    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderID: CurrentUserID,
        senderEmail: CurrentUserEmail,
        receiverID: recieverID,
        message: message,
        timestamp: timestamp,
        isRead: false);

    List<String> ids = [CurrentUserID, recieverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Stream<int> getNewMessagesCount(String userID, String otherUserID) {
    return getMessages(userID, otherUserID).map((snapshot) {
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        if (!doc['isRead'] && doc['receiverID'] == userID) {
          unreadCount++;
        }
      }
      return unreadCount;
    });
  }

  Future<void> markMessagesAsRead(String chatRoomID, String userID) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .where('receiverID', isEqualTo: userID)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}
