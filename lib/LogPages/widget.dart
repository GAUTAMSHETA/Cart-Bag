import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:super_market2/HomePage.dart';
import 'package:super_market2/LogPages/LogIn.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/maps.dart';
import 'package:super_market2/seller/seller_logpages/MapForGetAddress.dart';
import 'package:super_market2/seller/seller_services/ProductSelectionPage.dart';
import 'package:super_market2/seller/seller_services/Scanner.dart';
import 'package:super_market2/seller/seller_services/SellerHistory.dart';
import 'package:super_market2/seller/seller_services/SellerHomePage.dart';
import 'package:super_market2/seller/seller_services/SellerOrder.dart';
import 'package:super_market2/user/History.dart';
import 'package:super_market2/user/YourCard.dart';
import 'package:super_market2/user/YourOrder.dart';
import 'package:super_market2/user/displayStoreCategories.dart';

class Drower extends StatefulWidget {
  bool recruiter;
  Drower({this.recruiter});
  @override
  _DrowerState createState() => _DrowerState();
}

class _DrowerState extends State<Drower> {
  static String select = "Home";

  String uid = "";

  var email, name, photo = "NO";

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email").toString();
      name = prefs.getString("userName").toString();
      uid = prefs.getString("userNiId").toString();
      String _photo = prefs.getString("userPhotoUrl").toString();
      if (_photo != "null") {
        setState(() {
          photo = _photo;
        });
      }
      print(email + "\n" + name + "\n" + photo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 30,
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              name == null ? "" : name,
              style: TextStyle(color: Colors.black),
            ),
            accountEmail: Text(
              email == null ? "" : email,
              style: TextStyle(color: Colors.black),
            ),
            decoration: BoxDecoration(),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.black26,
              backgroundImage: photo == "NO"
                  ? AssetImage("assets/Images/app_icon.png")
                  : NetworkImage(photo),
            ),
          ),
          widget.recruiter
              ? Container()
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      select = "Location";
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyMaps()),
                    );
                  },
                  child: listTile("Location", Icons.location_on_rounded),
                ),
          GestureDetector(
            onTap: () {
              setState(() {
                select = "Home";
              });
              if (widget.recruiter) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SellerHomePage()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
            },
            child: listTile("Home", Icons.home),
          ),
          widget.recruiter
              ? Container()
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      select = "Your Cart";
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YourCard()),
                    );
                  },
                  child: listTile("Your Cart", Icons.local_grocery_store),
                ),
          GestureDetector(
            onTap: () {
              setState(() {
                select = "Your Orders";
              });
              if (widget.recruiter) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellerOrder()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => YourOrder()),
                );
              }
            },
            child: listTile("Your Orders", Icons.border_color),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                select = "History";
              });
              if (widget.recruiter) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SellerHistory()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => History()),
                );
              }
            },
            child: listTile("History", Icons.history),
          ),
          widget.recruiter
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      select = "Scanner";
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Scanner()),
                    );
                  },
                  child: listTile("Scanner", Icons.qr_code_scanner),
                )
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      select = "Register Your Market";
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapForGetAddress()),
                    );
                  },
                  child: listTile(
                      "Register Your Market", Icons.cloud_upload_rounded),
                ),
          widget.recruiter
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      select = "Edit Product";
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DisplayStoreCategories("", uid)),
                    );
                  },
                  child: listTile("Edit Product", Icons.edit_rounded),
                )
              : Container(),
          Container(
            height: SizeConfig.screenHeight,
            color: Colors.black12,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      select = "Settings";
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WordInProgress()),
                    );
                  },
                  child: listTile("Settings", Icons.settings),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      select = "Log Out";
                    });
                    signOut();
                  },
                  child: listTile("Log Out", Icons.logout),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget listTile(String text, IconData icon) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(color: select == text ? Colors.blue : null),
      ),
      leading: Icon(
        icon,
        color: select == text ? Colors.blue : null,
      ),
    );
  }

  Future signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("email");
      prefs.remove("userNiId");
      prefs.remove("userPhotoUrl");
      prefs.remove("userName");
      prefs.remove("recruiters");
      var out = await FirebaseAuth.instance.signOut().then((value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => LogInPage()),
            ModalRoute.withName('/'));
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class MySplashScreen extends StatefulWidget {
  MySplashScreen({this.recruiter});
  bool recruiter = false;

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  bool isCategoriesSelected = false;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  void _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DocumentReference userStore = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Recruiter")
        .collection(prefs.getString("userNiId").toString())
        .doc("Product");
    userStore.get().then((value) {
      if (value.data() != null) {
        setState(() {
          isCategoriesSelected = true;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      backgroundColor: Colors.white,
      seconds: 8,
      navigateAfterSeconds: widget.recruiter
          ? isCategoriesSelected
              ? SellerHomePage()
              : ProductSelectionPage(true)
          : HomePage(),
      title: Text(
        "Welcome to Cart Bag",
        style: TextStyle(color: Colors.black),
      ),
      image: Image.asset(
        "assets/Images/app_icon.png",
      ),
      photoSize: 140.0,
      loaderColor: Colors.black,
      loadingText: Text(
        "Loading.....",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class WordInProgress extends StatefulWidget {
  @override
  _WordInProgressState createState() => _WordInProgressState();
}

class _WordInProgressState extends State<WordInProgress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Work In Progress"),
            SizedBox(
              height: 79,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.black45,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                minHeight: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pop(context);
    });
  }
}

Container vegAndNonVeg(bool veg, double size, String productType) {
  return Container(
    margin:
        EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 3),
    width: size,
    height: size,
    color: veg ? Colors.green : Colors.red,
    child: Center(
      child: Container(
        width: size / 1.5,
        height: size / 1.5,
        color: Colors.white,
        child: Center(
          child: Container(
            width: size / 2.5,
            height: size / 2.5,
            decoration: BoxDecoration(
              color: veg ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    ),
  );
}
