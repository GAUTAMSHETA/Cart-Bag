import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/HomePage.dart';
import 'package:super_market2/LogPages/LogIn.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:super_market2/seller/seller_logpages/MapForGetAddress.dart';
import 'package:super_market2/seller/seller_logpages/SellerLogIn.dart';
import 'package:super_market2/service/DataProvider.dart';

class SellerSignUpPage extends StatefulWidget {
  @override
  _SellerSignUpPageState createState() => _SellerSignUpPageState();
}

class _SellerSignUpPageState extends State<SellerSignUpPage> {
  bool lodding = false;
  bool emailExist = false;
  bool passwordError = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final referenceDatase = FirebaseDatabase.instance;

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer timer;
  IconData icon = Icons.check_box_outline_blank;
  Color iconColer = Colors.red;
  File _image;
  String imageUrl;

  TextEditingController stateTextEdittingController =
      new TextEditingController();
  TextEditingController addressTextEdittingController =
      new TextEditingController();
  TextEditingController cityTextEdittingController =
      new TextEditingController();

  var items = [
    "Jammu and Kashmir",
    "Himachal Pradesh",
    "Punjab",
    "Chandigarh",
    "Uttarakhand",
    "Haryana",
    "Delhi",
    "Rajasthan",
    "Uttar  Pradesh",
    "Bihar",
    "Sikkim",
    "Arunachal Pradesh",
    "Nagaland",
    "Manipur",
    "Mizoram",
    "Tripura",
    "Meghlaya",
    "Assam",
    "West Bengal",
    "Jharkhand",
    "Odisha",
    "Chattisgarh",
    "Madhya Pradesh",
    "Gujarat",
    "Daman and Diu",
    "Dadra and Nagar haveli",
    "Maharashtra",
    "Andhra Pradesh",
    "Karnataka",
    "Goa",
    "Lakshwadeep",
    "Kerala",
    "Tamil Nadu",
    "Puducherry",
    "Andaman and Nicobar Islands",
    "Telangana"
  ];

  String yourName, storName, surname, fullname;
  String email;
  String password;
  String mobileNumber;
  String address, city, state;
  String pan, gst;
  int index = 0;

  TimeOfDay _open;
  TimeOfDay _close;

  String _openForDisplay = "";
  String _closeForDisplay = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      addressTextEdittingController.text = SellerPersonalData.address;
      address = SellerPersonalData.address;
      state = SellerPersonalData.state;
      stateTextEdittingController.text = SellerPersonalData.state;
      city = SellerPersonalData.locality;
      cityTextEdittingController.text = SellerPersonalData.locality;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/Images/SignUpText.png",
                color: Colors.black,
                scale: 0.7,
              ),
              // Textfield("First Name"),
              IndexedStack(
                index: index,
                children: [
                  Form(
                    key: formKey1,
                    child: Column(
                      children: [
                        Textfield("Your Name", null),
                        Textfield("Surname", null),
                        Textfield("Store Name", null),
                        _openClose(),
                        SizedBox(height: SizeConfig.blockSizeVertical * 4),
                        signUpButton("Continue")
                      ],
                    ),
                  ),
                  Form(
                    key: formKey2,
                    child: Column(
                      children: [
                        Textfield(
                            "Store Address", addressTextEdittingController),
                        Textfield("City", cityTextEdittingController),
                        Textfield("State", stateTextEdittingController),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockSizeHorizontal * 10,
                              vertical: SizeConfig.blockSizeVertical * 2),
                          child: imageUploader(),
                        ),
                        SizedBox(height: SizeConfig.blockSizeVertical * 4),
                        signUpButton("Done")
                      ],
                    ),
                  ),
                  Form(
                    key: formKey3,
                    child: Column(
                      children: [
                        Textfield("Pan Number", null),
                        Textfield("GST Number", null),
                        Textfield("Email Address", null),
                        Textfield("Password", null),
                        Textfield("Mobile Number", null),
                        SizedBox(height: SizeConfig.blockSizeVertical * 4),
                        signUpButton("Sign Up")
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _openClose() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 10,
          vertical: SizeConfig.blockSizeVertical),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              _getTime("Shop Opening Time").then((value) {
                setState(() {
                  _open = value;
                  _openForDisplay = "";

                  if (value.hour > 12) {
                    int temp = value.hour - 12;

                    if (temp.toString().length == 1) {
                      _openForDisplay = _openForDisplay + "0" + temp.toString();
                    } else if (temp.toString().length == 2) {
                      _openForDisplay = _openForDisplay + temp.toString();
                    }
                  } else {
                    if (value.hour.toString().length == 1) {
                      _openForDisplay =
                          _openForDisplay + "0" + value.hour.toString();
                    } else if (value.hour.toString().length == 2) {
                      _openForDisplay = _openForDisplay + value.hour.toString();
                    }
                  }

                  _openForDisplay = _openForDisplay + ":";

                  if (value.minute.toString().length == 1) {
                    _openForDisplay =
                        _openForDisplay + "0" + value.minute.toString();
                  } else if (value.minute.toString().length == 2) {
                    _openForDisplay = _openForDisplay + value.minute.toString();
                  }

                  if (value.hour > 12) {
                    _openForDisplay = _openForDisplay + " PM";
                  } else if (value.hour <= 12) {
                    _openForDisplay = _openForDisplay + " AM";
                  }
                });
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 8,
                  vertical: SizeConfig.blockSizeVertical),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey)),
              child: AutoSizeText(
                _open == null ? "Opening" : _openForDisplay,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _getTime("Shop Closeing Time").then((value) {
                setState(() {
                  _close = value;

                  _closeForDisplay = "";
                  if (value.hour > 12) {
                    int temp = value.hour - 12;

                    if (temp.toString().length == 1) {
                      _closeForDisplay =
                          _closeForDisplay + "0" + temp.toString();
                    } else if (temp.toString().length == 2) {
                      _closeForDisplay = _closeForDisplay + temp.toString();
                    }
                  } else {
                    if (value.hour.toString().length == 1) {
                      _closeForDisplay =
                          _closeForDisplay + "0" + value.hour.toString();
                    } else if (value.hour.toString().length == 2) {
                      _closeForDisplay =
                          _closeForDisplay + value.hour.toString();
                    }
                  }

                  _closeForDisplay = _closeForDisplay + ":";

                  if (value.minute.toString().length == 1) {
                    _closeForDisplay =
                        _closeForDisplay + "0" + value.minute.toString();
                  } else if (value.minute.toString().length == 2) {
                    _closeForDisplay =
                        _closeForDisplay + value.minute.toString();
                  }

                  if (value.hour > 12) {
                    _closeForDisplay = _closeForDisplay + " PM";
                  } else if (value.hour <= 12) {
                    _closeForDisplay = _closeForDisplay + " AM";
                  }
                });
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 8,
                  vertical: SizeConfig.blockSizeVertical),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey)),
              child: AutoSizeText(
                _close == null ? "Closeing" : _closeForDisplay,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<TimeOfDay> _getTime(String _string) {
    final now = DateTime.now();
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
      helpText: _string,
    );
  }

  DottedBorder imageUploader() {
    return DottedBorder(
      strokeWidth: 3,
      color: Colors.black,
      radius: Radius.circular(24),
      borderType: BorderType.RRect,
      dashPattern: [5, 4],
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockHorizontal * 3),
        margin:
            EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 0.5),
        child: Row(
          children: [
            Spacer(),
            Icon(
              icon,
              color: iconColer,
            ),
            Spacer(),
            RaisedButton.icon(
              onPressed: () async {
                await imagePickerAndUploder();
              },
              icon: Icon(
                Icons.upload_outlined,
                color: Colors.black,
              ),
              label: Text(
                "UPLOAD IMAGE",
                style: TextStyle(color: Colors.black),
              ),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future imagePickerAndUploder() async {
    if (formKey2.currentState.validate()) {
      final pickedFile =
          await ImagePicker().getImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          icon = Icons.check_box_outlined;
          iconColer = Colors.green;
        } else {
          print('No image selected.');
        }
      });
    }
  }

  Widget Textfield(String hint, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 10,
          vertical: SizeConfig.blockSizeVertical),
      child: TextFormField(
        obscureText: hint == "Password" ? true : false,
        controller: controller,
        minLines: 1,
        maxLines: hint == "Store Address" ? 2 : 1,
        enabled:
            (hint == "City" || hint == "Store Address" || hint == "State") &&
                    (hint.isNotEmpty)
                ? false
                : true,
        onChanged: (text) {
          if (hint == "Your Name") {
            yourName = text;
          } else if (hint == "Surname") {
            surname = text;
          } else if (hint == "Store Name") {
            storName = text;
          } else if (hint == "City") {
            city = text;
          } else if (hint == "State") {
            state = text;
          } else if (hint == "Pan Number") {
            pan = text;
          } else if (hint == "GST Number") {
            gst = text;
          } else if (hint == "Email Address") {
            email = text;
          } else if (hint == "Password") {
            password = text;
          } else if (hint == "Mobile Number") {
            mobileNumber = "+91" + text;
          }
        },
        validator: (value) {
          if (hint == "Your Name" ||
              hint == "City" ||
              hint == "Store Address" ||
              hint == "Store Name" ||
              hint == "Surname" ||
              hint == "State") {
            return value.isEmpty || value.length < 2 ? "invalid Input" : null;
          } else if (hint == "Pan Number") {
            return panVerification(pan, surname.substring(0, 1)) == "Yes"
                ? null
                : "Invalid Pan Number";
          } else if (hint == "GST Number") {
            return gstVerification(pan, gst, state) == "Yes"
                ? null
                : "Invalid GST Number";
          } else if (hint == "Email Address") {
            return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~}+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value) &&
                    emailExist == false
                ? null
                : "Please Enter Correct Email";
          } else if (hint == "Password") {
            return value.length > 6 && passwordError == false
                ? null
                : "Please provide password 6+ charater";
          } else if (hint == "Mobile Number") {
            if (value.isEmpty ||
                value.length < 10 ||
                isNumericUsing_tryParse(value) == false) {
              return "invalid Input";
            } else {
              if ((value.length == 13 && value.substring(0, 3) == "+91") ||
                  (value.length == 10)) {
                return null;
              } else {
                return "invalid Input";
              }
            }
          }
        },
        keyboardType: hint == "Mobile Number" ? TextInputType.number : null,
        maxLength: hint == "Mobile Number" ? 10 : null,
        textCapitalization: hint == "Pan Number" || hint == "GST Number"
            ? TextCapitalization.characters
            : TextCapitalization.words,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          suffixIcon: hint == "State"
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String value) {
                    setState(() {
                      state = value;
                      stateTextEdittingController.text = value;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return items.map<PopupMenuItem<String>>((String value) {
                      return new PopupMenuItem(
                          child: new Text(value), value: value);
                    }).toList();
                  },
                )
              : null,
        ),
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

  bool isNumericUsing_tryParse(String string) {
    final number = num.tryParse(string);
    if (number == null) {
      return false;
    }
    return true;
  }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void signUp() async {
    final ref = referenceDatase.reference().child("Super Market");
    DocumentReference users =
        FirebaseFirestore.instance.collection('Super Market').doc("Recruiters");
    CollectionReference users2 =
        FirebaseFirestore.instance.collection('Super Market');

    List<String> rectuiter = [];

    setState(() {
      lodding = true;
    });

    try {
      await users.get().then((value) async {
        for (int i = 0; i < value.data()["Data"].length; i++) {
          rectuiter.add(value.data()["Data"][i]["Email"]);
        }

        if (!rectuiter.contains(email)) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove("email");
          prefs.remove("userNiId");
          prefs.remove("userPhotoUrl");
          prefs.remove("userName");
          await FirebaseAuth.instance.signOut().then((value) async {
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(
              email: email,
              password: password,
            )
                .then((value1) async {
              FirebaseStorage fs = FirebaseStorage.instance;

              var rootReference = fs.ref();

              var image = rootReference
                  .child("Recruiter")
                  .child(value1.user.uid)
                  .child("Shop Image");

              image.child("SImage.png").putFile(_image).then((value) async {
                imageUrl = await value.ref.getDownloadURL();
              }).then((value) {
                ref
                    .child("Recruiter User")
                    .child(value1.user.uid)
                    .child("Personal Data")
                    .set({
                  "name": yourName + " " + surname,
                  "store name": storName,
                  "store address": address,
                  "city": city,
                  "state": state,
                  "pan number": pan,
                  "GST number": gst,
                  "email": email,
                  "password": password,
                  "mobile number": mobileNumber,
                  "latitude": SellerPersonalData.latitude,
                  "longitude": SellerPersonalData.longitude,
                  "open and close": "${_openForDisplay}/${_closeForDisplay}",
                }).then((value) {
                  Map<String, String> userInfoMap = {
                    "Email": value1.user.email,
                    'UID': value1.user.uid,
                  };
                  users.update({
                    "Data": FieldValue.arrayUnion([userInfoMap]),
                  }).then((value) {
                    String temp =
                        "${SellerPersonalData.latitude}:${SellerPersonalData.longitude}"
                            .toString()
                            .replaceAll(".", "#");

                    users2.doc("Store").update({
                      "Store name.$temp": [
                        storName,
                        address,
                        value1.user.uid,
                        imageUrl,
                        "${_openForDisplay}/${_closeForDisplay}",
                        true,
                      ],
                    }).then((value) {
                      users2.doc("Store").update({
                        "store uid": FieldValue.arrayUnion([
                          "${SellerPersonalData.latitude}:${SellerPersonalData.longitude}"
                        ]),
                      }).then((value) {
                        users2.doc("Store").update({
                          "search": FieldValue.arrayUnion([
                            "$storName, ${SellerPersonalData.subLocality}, ${SellerPersonalData.locality}:${value1.user.uid}"
                          ]),
                        });
                      }).then((value) {
                        prefs.setString("email", email);
                        prefs.setString("userNiId", value1.user.uid);
                        prefs.setString("userName", yourName + " " + surname);
                        prefs.setString("recruiters", "yes");

                        setState(() {
                          lodding = false;
                        });

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                              builder: (_) => MySplashScreen(recruiter: true)),
                        );
                      });
                    });
                  });
                });
              });
            }).catchError((e) async {
              if (e.code == 'user-not-found') {
                await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                )
                    .then((value) {
                  verifyEmail(value);
                }).catchError((e) {
                  setState(() {
                    lodding = false;
                  });
                  if (e.code == 'weak-password') {
                    showSnackbar('The password provided is too weak.');
                  } else if (e.code == 'email-already-in-use') {
                    showSnackbar('The account already exists for email.');
                  } else if (e.code == "invalid-email") {
                    showSnackbar("Invalid Email ID");
                  }
                });
              } else if (e.code == 'wrong-password') {
                showSnackbar('Wrong password provided for that user.');
                await FirebaseAuth.instance
                  ..sendPasswordResetEmail(email: email).then((value) {
                    showSnackbar(
                        'Password reset link has been send on ${email}');
                  });
                setState(() {
                  lodding = false;
                });
              }
            });
          });
        } else {
          showSnackbar("You are alredy recruiter");

          setState(() {
            lodding = false;
          });

          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => SellerLogInPage()),
            );
          });
        }
      });
    } catch (e) {
      setState(() {
        lodding = false;
      });
      print(e.toString());
    }
  }

  void verifyEmail(UserCredential userCredential) {
    userCredential.user.sendEmailVerification().then((value) {
      showSnackbar(
          "An Email has been sent to ${userCredential.user.email}\nPlease Verify");
      lodding = false;
    });
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerifird(userCredential);
    });
  }

  Future<void> checkEmailVerifird(UserCredential userCredential) async {
    final ref = referenceDatase.reference().child("Super Market");
    DocumentReference users =
        FirebaseFirestore.instance.collection('Super Market').doc("Recruiters");
    CollectionReference users2 =
        FirebaseFirestore.instance.collection('Super Market');

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await userCredential.user.reload();
    try {
      if (userCredential.user.emailVerified) {
        timer.cancel();
        print(timer.isActive);

        FirebaseStorage fs = FirebaseStorage.instance;

        var rootReference = fs.ref();

        var image = rootReference
            .child("Recruiter")
            .child(userCredential.user.uid)
            .child("Shop Image");

        image.child("SImage.png").putFile(_image).then((value) async {
          imageUrl = await value.ref.getDownloadURL();
        }).then((value) {
          ref
              .child("Recruiter User")
              .child(userCredential.user.uid)
              .child("Personal Data")
              .set({
            "name": yourName + " " + surname,
            "store name": storName,
            "store address": address,
            "city": city,
            "state": state,
            "pan number": pan,
            "GST number": gst,
            "email": email,
            "password": password,
            "mobile number": mobileNumber,
            "latitude": SellerPersonalData.latitude,
            "longitude": SellerPersonalData.longitude,
            "open and close": "${_openForDisplay}/${_closeForDisplay}",
          }).then((value) {
            ref
                .child("Simple User")
                .child(userCredential.user.uid)
                .child("Personal Data")
                .set({
              "name": yourName + " " + surname,
              "email": email,
              "password": password,
            }).then((value) {
              Map<String, String> userInfoMap = {
                "Email": userCredential.user.email,
                'UID': userCredential.user.uid,
              };
              users.update({
                "Data": FieldValue.arrayUnion([userInfoMap]),
              }).then((value) {
                String temp =
                    "${SellerPersonalData.latitude}:${SellerPersonalData.longitude}"
                        .toString()
                        .replaceAll(".", "#");

                users2.doc("Store").update({
                  "Store name.$temp": [
                    storName,
                    address,
                    userCredential.user.uid,
                    imageUrl,
                    "${_openForDisplay}/${_closeForDisplay}",
                    true,
                  ],
                }).then((value) {
                  users2.doc("Store").update({
                    "store uid": FieldValue.arrayUnion([
                      "${SellerPersonalData.latitude}:${SellerPersonalData.longitude}"
                    ]),
                  }).then((value) {
                    users2.doc("Store").update({
                      "search": FieldValue.arrayUnion([
                        "$storName, ${SellerPersonalData.subLocality}, ${SellerPersonalData.locality}:${userCredential.user.uid}"
                      ]),
                    });
                  });
                }).then((value) {
                  prefs.setString("email", email);
                  prefs.setString("userNiId", userCredential.user.uid);
                  prefs.setString("userName", yourName + " " + surname);
                  prefs.setString("recruiters", "yes");
                  setState(() {
                    lodding = false;
                  });
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                        builder: (_) => MySplashScreen(recruiter: true)),
                  );
                });
              });
            });
          });
        });
      }
    } catch (e) {
      setState(() {
        lodding = false;
      });
    }
  }

  Widget signUpButton(String text) {
    return lodding
        ? CircularProgressIndicator(
            strokeWidth: 5,
            backgroundColor: Colors.black45,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          )
        : RaisedButton(
            onPressed: () {
              bool emailExist = false;
              bool passwordError = false;
              if (text == "Continue" &&
                  formKey1.currentState.validate() &&
                  _openForDisplay != "" &&
                  _closeForDisplay != "") {
                setState(() {
                  index = 1;
                });
              } else if (text == "Done" &&
                  formKey2.currentState.validate() &&
                  _image != null) {
                setState(() {
                  index = 2;
                });
              } else if (text == "Sign Up" &&
                  formKey3.currentState.validate()) {
                signUp();
              } else if (_openForDisplay == "") {
                showSnackbar("Enter Shop Opening Time");
              } else if (_closeForDisplay == "") {
                showSnackbar("Enter Shop Closeing Time");
              } else if (_image == null) {
                showSnackbar("Upload Shop Image First");
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
}
