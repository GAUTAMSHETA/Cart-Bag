import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/LogIn.dart';
import 'package:super_market2/LogPages/widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString("email");
  var userNiId = prefs.getString("userNiId");
  var recruiter = prefs.getString("recruiters");
  runApp(MyApp(email: email,userNiId: userNiId,recruiters: recruiter,));
}

class MyApp extends StatefulWidget {
  var email,userNiId,recruiters;
  MyApp({this.email,this.userNiId,this.recruiters});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cart Bag",
      color: Color(0xff95afd0),
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Color(0xff95afd0),foregroundColor: Colors.black),
        tabBarTheme: TabBarTheme(labelColor: Colors.black)
      ),
      home: widget.email == null || widget.userNiId == null ? LogInPage() : widget.recruiters == "yes" ? MySplashScreen(recruiter: true) : MySplashScreen(recruiter: false),
    );
  }
}
