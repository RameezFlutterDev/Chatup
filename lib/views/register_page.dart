import 'dart:async';

import 'package:chatup/services/Auth/auth_service.dart';
import 'package:chatup/views/home_page.dart';
import 'package:chatup/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../Widgets/Textfields.dart';

class Register extends StatelessWidget {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _pwcontroller = TextEditingController();
  TextEditingController _cpwcontroller = TextEditingController();

  final RoundedLoadingButtonController _LoginbtnController =
      RoundedLoadingButtonController();

  Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 60,
                color: Colors.grey.shade600,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Lets create an account for you",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                controller: _emailcontroller,
                label: Text(
                  "Email",
                  style: GoogleFonts.poppins(),
                ),
                icn: Icon(Icons.email_outlined),
                obscuretext: false,
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                  controller: _pwcontroller,
                  label: Text(
                    "Password",
                    style: GoogleFonts.poppins(),
                  ),
                  icn: Icon(Icons.password_outlined),
                  obscuretext: true),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                  controller: _cpwcontroller,
                  label: Text(
                    "Confirm Password",
                    style: GoogleFonts.poppins(),
                  ),
                  icn: Icon(Icons.check_box_outlined),
                  obscuretext: true),
              SizedBox(
                height: 10,
              ),
              RoundedLoadingButton(
                width: 2000,
                borderRadius: 10,
                controller: _LoginbtnController,
                color: (Colors.grey.shade600),
                onPressed: () {
                  final _authService = AuthService();
                  if (_pwcontroller.text == _cpwcontroller.text) {
                    try {
                      _authService.SignUpWithEmailPassword(
                          _emailcontroller.text, _pwcontroller.text);
                      _LoginbtnController.success();
                      // Timer(Duration(seconds: 3), () {
                      //   _authService.SignInWithEmailPassword(
                      //       _emailcontroller.text, _pwcontroller.text);

                      //   LoginbtnController.success();
                      // });
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(title: Text(e.toString())),
                      );

                      _LoginbtnController.reset();
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(title: Text("Password dont match")),
                    );
                    _LoginbtnController.reset();
                  }
                },
                child: Text(
                  "Sign Up",
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a member? ",
                    style: GoogleFonts.poppins(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ));
                    },
                    child: Text(
                      "Log In",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
