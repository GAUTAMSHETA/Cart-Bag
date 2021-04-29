import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/SignUp.dart';
import 'package:super_market2/LogPages/forgotPassword.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:super_market2/seller/seller_logpages/SellerLogIn.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool signInLodding = false;

  final formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String email = "";
  var password;

  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
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
                    Image.asset(
                      "assets/Images/LogInLogo.png",
                    ),
                    LogInTextFieldContainer("Email Address"),
                    LogInTextFieldContainer("Password"),
                    SizedBox(height: SizeConfig.blockSizeVertical * 4),
                    LogInAndSignUpButton(),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => forgotPasswordPage()),
                        );
                      },
                      child: LogInTextContainer("Forgot Password"),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: LogInTextContainer("Not Registered? Sign Up"),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 2),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SellerLogInPage()),
                        );
                      },
                      child: LogInTextContainer("Log In as a Seller"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget LogInAndSignUpButton() {
    return signInLodding
        ? CircularProgressIndicator(
            strokeWidth: 5,
            backgroundColor: Colors.black45,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          )
        : RaisedButton(
            onPressed: () {
              setState(() {
                signInLodding = true;
              });
              if (formKey.currentState.validate()) {
                signInWithEmailAndPassword(email, password);
              } else {
                setState(() {
                  signInLodding = false;
                });
              }
            },
            padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockSizeVertical * 1.3,
                horizontal: SizeConfig.blockSizeHorizontal * 3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Text(
              "SIGN IN",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.black,
          );
  }

  Widget LogInTextContainer(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(color: Color(0xff747474)),
      ),
    );
  }

  IconButton getIcon(String string) {
    return IconButton(
      icon: showPassword
          ? Icon(Icons.remove_red_eye_sharp)
          : Icon(Icons.remove_red_eye_outlined),
      onPressed: () {
        setState(() {
          showPassword = !showPassword;
        });
      },
    );
  }

  Widget LogInTextFieldContainer(String hint) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 10,
          vertical: SizeConfig.blockSizeVertical),
      child: TextFormField(
        obscureText: hint == "Password" ? showPassword : false,
        onChanged: (text) {
          if (hint == "Email Address") {
            email = text;
          } else if (hint == "Password") {
            password = text;
          }
        },
        validator: (value) {
          if (hint == "Email Address") {
            return RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~}+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)
                ? null
                : "Please Enter Correct Email";
          } else if (hint == "Password") {
            return value.length > 6 ? null : "Please Enter Correct password";
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          // border: InputBorder.none,
          fillColor: Colors.white38,
          suffixIcon: hint == "Password" ? getIcon("Password") : null,
          filled: true,
          border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    final fb = FirebaseDatabase.instance.reference().child("Super Market");

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      fb
          .child("Simple User/${userCredential.user.uid}/Personal Data")
          .orderByKey()
          .once()
          .then((DataSnapshot snapshot) async {
        var data = snapshot.value;
        if (data["Mamu Banavi Gaya"] != null) {
          if (int.tryParse(data["Mamu Banavi Gaya"]) >= 10) {
            await FirebaseAuth.instance.signOut().then((value) {
              setState(() {
                signInLodding = false;
              });
              showSnackbar('Bov mamu banavi lidha bas have');
            });
          } else {
            if (userCredential != null) {
              setState(() {
                signInLodding = false;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              fb
                  .child("Simple User/${userCredential.user.uid}/Personal Data")
                  .orderByKey()
                  .once()
                  .then((DataSnapshot snapshot) {
                var data = snapshot.value;
                if (data["Mamu Banavi Gaya"] != null) {}
                prefs.setString("email", data["email"]);
                prefs.setString("userName", data["name"]);
                prefs.setString("userNiId", userCredential.user.uid);
                if (data["Photo URL"] != null) {
                  prefs.setString("userPhotoUrl", data["Photo URL"]);
                }
              }).then((value) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                      builder: (_) => MySplashScreen(recruiter: false)),
                );
              }).catchError((onError) {
                setState(() {
                  signInLodding = false;
                });
                showSnackbar(
                    "Your Verification is Pandding.\nPlease do it first.");
              });
            }
          }
        } else {
          if (userCredential != null) {
            setState(() {
              signInLodding = false;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            fb
                .child("Simple User/${userCredential.user.uid}/Personal Data")
                .orderByKey()
                .once()
                .then((DataSnapshot snapshot) {
              var data = snapshot.value;
              if (data["Mamu Banavi Gaya"] != null) {}
              prefs.setString("email", data["email"]);
              prefs.setString("userName", data["name"]);
              prefs.setString("userNiId", userCredential.user.uid);
              if (data["Photo URL"] != null) {
                prefs.setString("userPhotoUrl", data["Photo URL"]);
              }
            }).then((value) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                    builder: (_) => MySplashScreen(recruiter: false)),
              );
            }).catchError((onError) {
              setState(() {
                signInLodding = false;
              });
              showSnackbar(
                  "Your Verification is Pandding.\nPlease do it first.");
            });
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackbar('No user found for that email.');
        setState(() {
          signInLodding = false;
        });
      } else if (e.code == 'wrong-password') {
        showSnackbar('Wrong password provided for that user.');
        setState(() {
          signInLodding = false;
        });
      }
    } catch (e) {
      setState(() {
        signInLodding = false;
      });
      showSnackbar(e);
    }
  }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
