import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:super_market2/SizeConfig.dart';

class forgotPasswordPage extends StatefulWidget {
  @override
  _forgotPasswordPageState createState() => _forgotPasswordPageState();
}

class _forgotPasswordPageState extends State<forgotPasswordPage> {
  bool passwordLodding = false;
  bool emailExist = true;

  final formKey = GlobalKey<FormState>();

  String email = "";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/Images/LogInBackground.jpg",
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            fit: BoxFit.fill,
          ),
          Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/Images/LogInLogo.png"),
                    LogInTextFieldContainer("Enter your Email Address"),
                    SizedBox(height: SizeConfig.blockSizeVertical * 4),
                    forgotPasswordButton(),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget forgotPasswordButton() {
    return passwordLodding
        ? CircularProgressIndicator(
            strokeWidth: 5,
            backgroundColor: Colors.black45,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          )
        : RaisedButton(
            onPressed: () {
              emailExist = true;
              setState(() {
                passwordLodding = true;
              });
              Timer(Duration(milliseconds: 500), () {
                setState(() {
                  passwordLodding = false;
                });
              });
              if (formKey.currentState.validate()) {
                resetPassword(email);
              }
            },
            padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockSizeVertical * 1.3,
                horizontal: SizeConfig.blockSizeHorizontal * 3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Text(
              "Send Link",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.black,
          );
  }

  Widget forgotPasswordTextContainer(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(color: Color(0xff747474)),
      ),
    );
  }

  Widget LogInTextFieldContainer(String hint) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 10,
          vertical: SizeConfig.blockSizeVertical),
      child: TextFormField(
        onChanged: (text) {
          email = text;
        },
        validator: (value) {
          return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~}+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value) &&
                  emailExist == true
              ? null
              : "Please Enter Correct Email";
        },
        decoration: InputDecoration(
          hintText: hint,
          // border: InputBorder.none,
          fillColor: Colors.white38,
          filled: true,
          border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance
      ..sendPasswordResetEmail(email: email);
  }
}
