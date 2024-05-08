import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  const ChatPage({super.key, required this.receiverEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat Page",
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }
}
