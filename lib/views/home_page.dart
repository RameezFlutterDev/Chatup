import 'package:chatup/services/Auth/auth_service.dart';
import 'package:chatup/services/chat/chat_service.dart';
import 'package:chatup/Widgets/list_tile.dart';
import 'package:chatup/views/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chat_page.dart';

class HomePage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  HomePage({super.key});
  void logout() {
    final _authService = AuthService();
    _authService.SignOutUser();
  }

  final _chatService = ChatService();
  User? _getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "ChatUp",
          style: GoogleFonts.poppins(),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey.shade100,
        child: Column(
          children: [
            DrawerHeader(
                child: Icon(
              Icons.message,
              size: 40,
              color: Colors.grey.shade600,
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                leading: Icon(Icons.home),
                title: Text(
                  "HOME",
                  style: GoogleFonts.nunito(
                      letterSpacing: 0.6, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text(
                  "SETTINGS",
                  style: GoogleFonts.nunito(
                      letterSpacing: 0.6, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  "LOGOUT",
                  style: GoogleFonts.nunito(
                      letterSpacing: 0.6, fontWeight: FontWeight.bold),
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
        return ListView(
            children: snapshot.data!
                .map<Widget>(
                    (userData) => _buildUserListItem(userData, context))
                .toList());
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData['email'] != _getCurrentUser()!.email) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: UserTile(
            text: userData["email"],
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      receiverEmail: userData["email"],
                    ),
                  ));
            }),
      );
    } else {
      return Container();
    }
  }
}
