import 'package:chatup/services/Auth/auth_service.dart';
import 'package:chatup/services/chat/chat_service.dart';
import 'package:chatup/Widgets/list_tile.dart';
import 'package:chatup/views/login_page.dart';
import 'package:chatup/views/prof_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  late String un;

  void logout() {
    final _authService = AuthService();
    _authService.SignOutUser();
  }

  final _chatService = ChatService();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade600,
        centerTitle: true,
        title: Text(
          "ChatUp",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
        shadowColor: Colors.amber,
      ),
      drawer: Drawer(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.purple.shade500,
        child: Column(
          children: [
            DrawerHeader(
                child: Icon(
              Icons.message,
              size: 40,
              color: Colors.white,
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                leading: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                title: Text(
                  "HOME",
                  style: GoogleFonts.nunito(
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text(
                  "SETTINGS",
                  style: GoogleFonts.nunito(
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfSettings(
                          username: un,
                        ),
                      ));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text(
                  "LOGOUT",
                  style: GoogleFonts.nunito(
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  logout();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Card(
              color: Colors.grey.shade300,
              elevation: 100,
              child: ListView(
                  children: snapshot.data!
                      .map((userData) => _buildUserListItem(userData))
                      .toList()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData) {
    if (userData['email'] != getCurrentUser()!.email) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: StreamBuilder<int>(
          stream: _chatService.getNewMessagesCount(
              getCurrentUser()!.uid, userData['uid']),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("StreamBuilder error: ${snapshot.error}");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            int newMessagesCount = snapshot.data ?? 0;

            return UserTile(
              avatarURL: userData['avatarURL'],
              text: userData["Username"],
              messageCount: newMessagesCount,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverEmail: userData["email"],
                      recieverID: userData['uid'],
                      receiverUsername: userData['Username'],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    } else {
      un = userData["Username"];
      return Container();
    }
  }
}
