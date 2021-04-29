import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/helper.dart';
import 'package:super_market2/seller/seller_services/SellerHomePage.dart';

class ProductSelectionPage extends StatefulWidget {
  bool isFirstTime;

  ProductSelectionPage(this.isFirstTime);

  @override
  _ProductSelectionPageState createState() => _ProductSelectionPageState();
}

class _ProductSelectionPageState extends State<ProductSelectionPage> {
  String userID;

  final referenceDatase = FirebaseDatabase.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
      if (widget.isFirstTime) {
        if (value.data() != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => SellerHomePage(),
            ),
          );
        }
      } else {
        List cList = value.get("Categories");
        for (var i in cList) {
          for (int j = 0; j < productCategories.length; j++) {
            if (i == productCategories[j][0]) {
              setState(() {
                productCategories[j][2] = !productCategories[j][2];
              });
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Select the Categories",style: TextStyle(color: Colors.black),),
        actions: [
          Center(
            widthFactor: 2,
            child: InkWell(
              onTap: () async {
                try {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  userID = prefs.getString("userNiId");
                  List temp = [];

                  for (List i in productCategories) {
                    if (i[2] == true) {
                      temp.add(i[0]);
                    }
                  }

                  if (temp.length != 0) {
                    DocumentReference userStore = FirebaseFirestore.instance
                        .collection('Super Market')
                        .doc("Recruiter")
                        .collection(userID)
                        .doc("Product");

                    userStore.set({
                      "Categories": FieldValue.arrayUnion(temp),
                    }).then((value) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => SellerHomePage(),
                        ),
                      );
                    });
                  } else {
                    showSnackbar("Select your categories.....");
                  }
                } on Exception catch (e) {
                  showSnackbar(e.toString());
                }
              },
              child: AutoSizeText("Done",style: TextStyle(color: Colors.black),),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(11, (index) {
            return Card(
              margin: EdgeInsets.all(5.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: InkWell(
                onTap: () {
                  setState(() {
                    productCategories[index][2] = !productCategories[index][2];
                  });
                },
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              productCategories[index][1],
                              height: 100,
                              width: SizeConfig.screenWidth,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3, top: 5),
                            child: AutoSizeText(
                              productCategories[index][0],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: productCategories[index][2]
                            ? Colors.black12
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: productCategories[index][2]
                            ? Icon(Icons.check_circle)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
