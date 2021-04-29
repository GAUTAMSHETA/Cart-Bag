import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/seller/seller_services/AddNewProduct.dart';
import 'package:super_market2/seller/seller_services/AddProductFromServer.dart';

class SellerHomePage extends StatefulWidget {
  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  String categories = "Select Categories";
  String userID;

  final referenceDatase = FirebaseDatabase.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> yourCategories = ["Select Categories"];
  List<String> productList = [];
  List<String> productListForDisplay = [];

  TextEditingController searchTextEditingController = TextEditingController();

  bool storeOpen = true;
  String storetime = "";

  String storeKey = '';

  @override
  void initState() {
    super.initState();
    getCategories();
    _getStoreDitails();
  }

  Future _getStoreDitails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userNiId");

    final fb = FirebaseDatabase.instance.reference().child("Super Market");

    fb
        .child("Recruiter User/${userID}/Personal Data")
        .orderByKey()
        .once()
        .then((value) {
      storeKey =
          "${value.value["latitude"].toString().replaceAll(".", "#")}:${value.value["longitude"].toString().replaceAll(".", "#")}";
    }).then((value) {
      DocumentReference users = FirebaseFirestore.instance
          .collection('Super Market')
          .doc("Store");

      users.get().then((value) {
        print(value.get("Store name")[storeKey][4]);
        print(value.get("Store name")[storeKey][5]);

        setState(() {
          storetime = value.get("Store name")[storeKey][4];
          storeOpen = value.get("Store name")[storeKey][5];
        });
      });
    });
  }

  Future getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userNiId");

    DocumentReference users = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Recruiter")
        .collection(userID)
        .doc("Product");

    await users.get().then((value) async {
      for (int i = 0; i < value.data()["Categories"].length; i++) {
        setState(() {
          yourCategories.add(value.data()["Categories"][i]);
        });
      }
    });
  }

  void getProductList() async {
    DocumentReference users = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Product Categories")
        .collection("Product Collection")
        .doc(categories);

    await users.get().then((value) async {
      productList.clear();
      productListForDisplay.clear();
      setState(() {
        print("\n\n\n\n");
        print(value.data()["List"]);
        print("\n\n\n\n");
        productList = List.from(value.data()["List"]);
        productListForDisplay = List.from(value.data()["List"]);
      });
      print(productList);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Add a Product",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Center(
            child: AutoSizeText(
              storeOpen ? "Open" : "Close",
              style: TextStyle(color: Colors.black),
            ),
          ),
          Switch(
            value: storeOpen,
            activeColor: Colors.black,
            onChanged: (value) {
              setState(() {
                storeOpen = !storeOpen;
              });
              FirebaseFirestore.instance
                  .collection('Super Market')
                  .doc("Store").update({
                "Store name.$storeKey" : FieldValue.arrayRemove([!storeOpen]),
              }).then((value) {
                FirebaseFirestore.instance
                    .collection('Super Market')
                    .doc("Store").update({
                  "Store name.$storeKey" : FieldValue.arrayUnion([storeOpen]),
                });
              });
            },
          ),
        ],
      ),
      drawer: Drower(recruiter: true),
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Container1(),
            productList.isEmpty ? notSelectedContainer() : container2(),
          ],
        ),
      ),
    );
  }

  Expanded notSelectedContainer() {
    return Expanded(
      child: Center(
        child: Opacity(
          opacity: 0.7,
          child: Text(
            "  Categories \nNot Selected",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Expanded container2() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: SizeConfig.safeBlockVertical * 3,
            horizontal: SizeConfig.blockSizeHorizontal * 5),
        margin: EdgeInsets.symmetric(
            vertical: SizeConfig.safeBlockVertical * 1.5,
            horizontal: SizeConfig.blockSizeHorizontal * 2.5),
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            searchBar(),
            productListForDisplay.isEmpty ? Spacer() : Container(),
            productListForDisplay.isEmpty
                ? RaisedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              AddNewProduct(productType: categories),
                        ),
                      );
                    },
                    icon: Icon(Icons.add),
                    label: Text("ADD PRODUCT"),
                    color: Color(0xffa9e1eb),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  )
                : listView(),
          ],
        ),
      ),
    );
  }

  Expanded listView() {
    return Expanded(
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        itemCount: productListForDisplay.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            splashColor: Colors.white70,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => AddProductFromServer(
                          productType: categories,
                          productName: productListForDisplay[index],
                        )),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: AutoSizeText(productListForDisplay[index]),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          color: Colors.black,
        ),
      ),
    );
  }

  Container searchBar() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.safeBlockVertical * 2),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: searchTextEditingController,
        decoration: InputDecoration(
          icon: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Icon(Icons.search),
          ),
          hintText: "Search",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            productListForDisplay.clear();
          });
          for (String i in productList) {
            if (RegExp(".*${value.toUpperCase()}.*")
                .hasMatch(i.toUpperCase())) {
              setState(() {
                productListForDisplay.add(i);
              });
            }
          }
        },
      ),
    );
  }

  Container Container1() {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: SizeConfig.safeBlockVertical * 2,
          horizontal: SizeConfig.blockSizeHorizontal * 3),
      margin: EdgeInsets.symmetric(
          vertical: SizeConfig.safeBlockVertical * 1.5,
          horizontal: SizeConfig.blockSizeHorizontal * 2.5),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      width: SizeConfig.safeBlockHorizontal * 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "List New Product - Select Categories First  ",
            style: TextStyle(color: Colors.black),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 2.5),
            margin: EdgeInsets.symmetric(
                vertical: SizeConfig.blockSizeVertical * 1.5),
            decoration: BoxDecoration(
              color: Colors.yellow[200],
              borderRadius: BorderRadius.circular(10),
            ),
            width: SizeConfig.safeBlockHorizontal * 100,
            child: DropdownButton<String>(
              value: categories,
              icon: const Icon(
                Icons.arrow_downward,
                color: Colors.black,
              ),
              isExpanded: true,
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              underline: Container(color: Colors.yellow),
              onChanged: (String newValue) {
                setState(() {
                  categories = newValue;
                });
                getProductList();
              },
              items:
                  yourCategories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
