import 'package:chatbox/chatbox.dart';
import 'package:chatup/services/Auth/auth_service.dart';
import 'package:chatup/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String recieverID;
  final String receiverUsername;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.recieverID,
    required this.receiverUsername,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    String chatRoomID = _getChatRoomID(widget.recieverID);
    String currentUserID = authService.getCurrentUser()!.uid;
    chatService.markMessagesAsRead(chatRoomID, currentUserID);
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await chatService.sendMessage(widget.recieverID, _messageController.text);
      _messageController.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _getChatRoomID(String otherUserID) {
    List<String> ids = [authService.getCurrentUser()!.uid, otherUserID];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.purple,
        title: Text(
          widget.receiverUsername,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
                  color: Colors.purple.shade200, child: _buildMessageList())),
          _builduserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = authService.getCurrentUser()!.uid;

    return StreamBuilder(
      stream: chatService.getMessages(senderID, widget.recieverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          !isCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),

          decoration: BoxDecoration(
            borderRadius: !isCurrentUser
                ? BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
            color: isCurrentUser ? Colors.green : Colors.red.shade700,
          ),
          // child: ChatBox(
          //     recieved: !isCurrentUser,
          //     message: data['message'],
          //     textColor: Colors.white,
          //     chatBoxColor: isCurrentUser ? Colors.green : Colors.red.shade700,
          //     time: DateFormat("h:mm a")
          //         .format((data["timestamp"] as Timestamp).toDate()))

          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['message'],
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                Text(
                  DateFormat("h:mm")
                      .format((data["timestamp"] as Timestamp).toDate()),
                  style: GoogleFonts.nunito(fontSize: 10, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _builduserInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.purple.shade200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.purple.shade200,
                alignment: Alignment.center,
                child: TextField(
                  textAlignVertical: TextAlignVertical.top,
                  controller: _messageController,
                  decoration: InputDecoration(
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: sendMessage,
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    label: Text("Enter your Message"),
                    fillColor: Colors.white54,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 0, color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 0, color: Colors.purple),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
