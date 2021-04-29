import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/HomePage.dart';
import 'package:super_market2/LogPages/LogIn.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool signUpLodding = false;
  bool googleLodding = false;
  final referenceDatase = FirebaseDatabase.instance;

  Timer timer;

  final formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController userNameTextEdittingController =
      new TextEditingController();

  String firstName = "";
  String lastName = "";
  String fullName = "";
  String email = "";
  var password;
  var confirmPassword;

  bool showPassword = true;
  bool showCPassword = true;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/Images/SignUpText.png",
                  color: Colors.black,
                  scale: 0.7,
                ),
                // Textfield("First Name"),
                Textfield("First Name"),
                Textfield("Last Name"),
                Textfield("Email Address"),
                Textfield("Create a Password"),
                Textfield("Confirm a Password"),
                SizedBox(height: SizeConfig.blockSizeVertical * 4),
                signUpButton("SIGN UP"),
                SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      googleLodding = true;
                    });
                    linkGoogleAndTwitter(context);
                  },
                  child: googleLodding
                      ? CircularProgressIndicator(
                          strokeWidth: 5,
                          backgroundColor: Colors.black45,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white70),
                        )
                      : TextContainer("Sign up with Google"),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 2.5),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LogInPage()),
                    );
                  },
                  child: TextContainer("Already have an Account? LogIn"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconButton getIcon(String string) {
    return IconButton(
      icon: Icon(Icons.remove_red_eye_sharp),
      onPressed: () {
        if (string == "Create a Password") {
          setState(() {
            showPassword = !showPassword;
          });
        } else {
          setState(() {
            showCPassword = !showCPassword;
          });
        }
      },
    );
  }

  IconButton getCIcon(String string) {
    return IconButton(
      icon: Icon(Icons.remove_red_eye_outlined),
      onPressed: () {
        if (string == "Create a Password") {
          setState(() {
            showPassword = !showPassword;
          });
        } else {
          setState(() {
            showCPassword = !showCPassword;
          });
        }
      },
    );
  }

  Widget Textfield(String hint) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 10,
          vertical: SizeConfig.blockSizeVertical),
      child: TextFormField(
        obscureText: hint == "Create a Password"
            ? showPassword
            : hint == "Confirm a Password"
                ? showCPassword
                : false,
        onChanged: (text) {
          if (hint == "First Name") {
            firstName = text;
          } else if (hint == "Last Name") {
            lastName = text;
          } else if (hint == "Email Address") {
            email = text;
          } else if (hint == "Create a Password") {
            password = text;
          } else if (hint == "Confirm a Password") {
            confirmPassword = text;
          }
          fullName = firstName + " " + lastName;
        },
        validator: (value) {
          if (hint == "First Name") {
            return value.isEmpty || value.length < 2 ? "invalid Input" : null;
          } else if (hint == "Last Name") {
            return value.isEmpty || value.length < 2 ? "invalid Input" : null;
          } else if (hint == "Email Address") {
            return RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~}+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)
                ? null
                : "Please Enter Correct Email";
          } else if (hint == "Create a Password") {
            return value.length > 6
                ? null
                : "Please provide password 6+ charater";
          } else if (hint == "Confirm a Password") {
            return value != password ? "Password is not same" : null;
          }
        },
        decoration: InputDecoration(
            hintText: hint,
            suffixIcon: hint == "Confirm a Password"
                ? showCPassword
                    ? getIcon("Confirm a Password")
                    : getCIcon("Confirm a Password")
                : hint == "Create a Password"
                    ? showPassword
                        ? getIcon("Create a Password")
                        : getCIcon("Create a Password")
                    : null,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
      ),
    );
  }

  Widget TextContainer(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(color: Color(0xff747474)),
      ),
    );
  }

  Widget signUpButton(String text) {
    return signUpLodding
        ? CircularProgressIndicator(
            strokeWidth: 5,
            backgroundColor: Colors.black45,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          )
        : RaisedButton(
            onPressed: () {
              setState(() {
                signUpLodding = true;
              });
              if (formKey.currentState.validate()) {
                signUpwithEmailAndPassword(email, confirmPassword);
              } else {
                setState(() {
                  signUpLodding = false;
                });
              }
            },
            padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockSizeVertical * 1.3,
                horizontal: SizeConfig.blockSizeHorizontal * 3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.black,
          );
  }

  Future signUpwithEmailAndPassword(String email, String password) async {
    try {
      UserCredential firebaseUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (firebaseUser != null) {
        setState(() {
          signUpLodding = false;
        });
        showSnackbar("your Sing Up done");
        verifyEmail(firebaseUser);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackbar('The password provided is too weak.');
        setState(() {
          signUpLodding = false;
        });
      } else if (e.code == 'email-already-in-use') {
        showSnackbar('The account already exists for email.');
        setState(() {
          signUpLodding = false;
        });
      } else if (e.code == "invalid-email") {
        showSnackbar("invalid Email ID");
        setState(() {
          signUpLodding = false;
        });
      }
    } catch (e) {
      showSnackbar(e.toString());
      setState(() {
        signUpLodding = false;
      });
    }
  }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void verifyEmail(UserCredential userCredential) {
    userCredential.user.sendEmailVerification().then((value) {
      showSnackbar(
          "An Email has been sent to ${userCredential.user.email}\nPlease Verify");
    });
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerifird(userCredential);
    });
  }

  Future<void> checkEmailVerifird(UserCredential userCredential) async {
    final ref = referenceDatase.reference().child("Super Market");

    User user = FirebaseAuth.instance.currentUser;

    try {
      await user.reload();
      if (user.emailVerified) {
        timer.cancel();
        print(timer.isActive);
        ref
            .child("Simple User")
            .child(userCredential.user.uid)
            .child("Personal Data")
            .set({
          "name": fullName,
          "email": email,
          "password": password,
        }).then((value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("email", email);
          prefs.setString("userNiId", userCredential.user.uid);
          prefs.setString("userName", fullName);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
                builder: (_) => MySplashScreen(recruiter: false)),
          );
        });
      }
    } catch (e) {
      print(e.toString());
      print("\n\n\n\n\n\n");
      showSnackbar(e.toString());
    }
  }

  Future<void> linkGoogleAndTwitter(BuildContext context) async {
    final ref = referenceDatase.reference().child("Super Market");

    // Trigger the Google Authentication flow.
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // Create a new credential.

      final GoogleAuthCredential googleCredential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential].
      final UserCredential googleFirebaseUser = await FirebaseAuth.instance
          .signInWithCredential(googleCredential)
          .catchError((onError) {
        showSnackbar("Some Error is occurred, Please Try Again !! $onError");
        print(onError.toString());
        print("\n\n\n\n");
        setState(() {
          googleLodding = false;
        });
      });

      if (googleFirebaseUser != null) {
        ref
            .child("Simple User/${googleFirebaseUser.user.uid}/Personal Data")
            .orderByKey()
            .once()
            .then((DataSnapshot snapshot) async {
          var data = snapshot.value;
          if (data != null) {
            if (data["Mamu Banavi Gaya"] != null) {
              if (int.tryParse(data["Mamu Banavi Gaya"]) >= 10) {
                await FirebaseAuth.instance.signOut().then((value) {
                  setState(() {
                    googleLodding = false;
                  });
                  showSnackbar('Bov mamu banavi lidha bas have');
                });
              } else {
                if (googleFirebaseUser != null) {
                  ref
                      .child("Simple User")
                      .child(googleFirebaseUser.user.uid)
                      .child("Personal Data")
                      .update({
                    "name": googleUser.displayName,
                    "email": googleUser.email,
                    "Photo URL": googleUser.photoUrl,
                  }).then((value) async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString("email", googleUser.email);
                    prefs.setString("userNiId", googleFirebaseUser.user.uid);
                    prefs.setString("userName", googleUser.displayName);
                    prefs.setString("userPhotoUrl", googleUser.photoUrl);
                    setState(() {
                      googleLodding = false;
                    });
                    showSnackbar("your Sing Up done");
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                          builder: (_) => MySplashScreen(recruiter: false)),
                    );
                  });
                }
              }
            } else {
              if (googleFirebaseUser != null) {
                ref
                    .child("Simple User")
                    .child(googleFirebaseUser.user.uid)
                    .child("Personal Data")
                    .update({
                  "name": googleUser.displayName,
                  "email": googleUser.email,
                  "Photo URL": googleUser.photoUrl,
                }).then((value) async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString("email", googleUser.email);
                  prefs.setString("userNiId", googleFirebaseUser.user.uid);
                  prefs.setString("userName", googleUser.displayName);
                  prefs.setString("userPhotoUrl", googleUser.photoUrl);
                  setState(() {
                    googleLodding = false;
                  });
                  showSnackbar("your Sing Up done");
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                        builder: (_) => MySplashScreen(recruiter: false)),
                  );
                });
              }
            }
          } else {
            if (googleFirebaseUser != null) {
              ref
                  .child("Simple User")
                  .child(googleFirebaseUser.user.uid)
                  .child("Personal Data")
                  .update({
                "name": googleUser.displayName,
                "email": googleUser.email,
                "Photo URL": googleUser.photoUrl,
                "Mamu Banavi Gaya": 0,
              }).then((value) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString("email", googleUser.email);
                prefs.setString("userNiId", googleFirebaseUser.user.uid);
                prefs.setString("userName", googleUser.displayName);
                prefs.setString("userPhotoUrl", googleUser.photoUrl);
                setState(() {
                  googleLodding = false;
                });
                showSnackbar("your Sing Up done");
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                      builder: (_) => MySplashScreen(recruiter: false)),
                );
              });
            }
          }
        }).catchError((e) {
          showSnackbar("Some Error is occurred, Please Try Again !! ");
          print(e.toString());
          print("\n\n\n\n");
          setState(() {
            googleLodding = false;
          });
        });
      }
    } catch (e) {
      showSnackbar("Some Error is occurred, Please Try Again !! ");
      print(e.toString());
      print("\n\n\n\n");
      setState(() {
        googleLodding = false;
      });
    }
  }
}
