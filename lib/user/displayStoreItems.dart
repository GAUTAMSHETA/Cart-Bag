import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/user/displayStoreCategories.dart';
import 'package:super_market2/user/utils/card_data_helper.dart';
import 'package:super_market2/user/models/CardData.dart';
import 'package:super_market2/user/utils/displayProduct.dart';

class DisplayStoreItems extends StatefulWidget {
  String productType;
  String storeUid;
  String storeName;

  DisplayStoreItems(this.storeUid, this.productType, this.storeName);
  @override
  _DisplayStoreItemsState createState() => _DisplayStoreItemsState();
}

class _DisplayStoreItemsState extends State<DisplayStoreItems> {
  List productData = [];

  List productDataForDisplay = [];

  Map<int, List> queryList = {};

  bool isSearching = false;
  bool isLoading = true;

  var checkListTable;
  String data = "";

  String todayDate = DateFormat("dd MMM yyyy").format(DateTime.now());

  CardDataDatabaseHelper cardDataDatabaseHelper = CardDataDatabaseHelper();

  @override
  void initState() {
    super.initState();

    DocumentReference userStore = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Recruiter")
        .collection(widget.storeUid)
        .doc(widget.productType);
    userStore.get().then((snap) {
      if (snap.data() != null) {
        userStore.get().then((value) {
          for (var i in value.data()["List"]) {
            List temp = [];
            setState(() {
              temp.add(value.get(i)[0]);
              temp.add(value.get(i)[1]);
              temp.add(value.get(i)[2]);
              temp.add(value.get(i)[3]);
              temp.add(value.get(i)[4]);
              if (widget.productType == "Grocery" ||
                  widget.productType == "Biscuits & Cookies" ||
                  widget.productType == "Fruits & Vegetables" ||
                  widget.productType == "Dairy & Bakery") {
                temp.add(value.get(i)[5]);
                temp.add(value.get(i)[6]["Images"]);
              } else {
                temp.add(value.get(i)[5]["Images"]);
              }
              productData.add(temp);
            });
          }
        }).then((value) {
          productDataForDisplay = List.from(productData);
          setState(() {
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isLoading = false;
          data = "No Data";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text(
                widget.productType,
                style: TextStyle(color: Colors.black),
              )
            : TextFormField(
                onChanged: (value) {
                  setState(() {
                    productDataForDisplay.clear();

                    for (int i = 0; i < productData.length; i++) {
                      if (RegExp(".*${value.toUpperCase()}.*")
                          .hasMatch(productData[i][0].toUpperCase())) {
                        productDataForDisplay.add(productData[i]);
                      }
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.black),
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
        actions: [
          IconButton(
            icon:
                !isSearching ? Icon(Icons.search) : Icon(Icons.cancel_outlined),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  productDataForDisplay.clear();

                  setState(() {
                    productDataForDisplay = List.from(productData);
                  });
                }
              });
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drower(recruiter: false),
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : data == ""
              ? RefreshIndicator(
                  child: ListView.builder(
                    itemCount: productDataForDisplay.length,
                    itemBuilder: (BuildContext context, int position) {
                      return prosuctCard(position);
                    },
                  ),
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  onRefresh: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(builder: (_) => super.widget),
                    );
                  },
                )
              : Center(
                  child: Text(
                    data,
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
    );
  }

  InkWell prosuctCard(int index) {
    PageController pageController = PageController(initialPage: 0);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayProduct(
                widget.productType,
                widget.storeUid,
                widget.storeName,
                productDataForDisplay[index]),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockHorizontal * 1,
            vertical: SizeConfig.safeBlockVertical * 1),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: SizeConfig.safeBlockHorizontal * 35,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: Colors.grey[200],
              child: Image.network(
                widget.productType == "Grocery" ||
                        widget.productType == "Biscuits & Cookies" ||
                        widget.productType == "Fruits & Vegetables" ||
                        widget.productType == "Dairy & Bakery"
                    ? productDataForDisplay[index][6][0]
                    : productDataForDisplay[index][5][0],
                width: 50,
                fit: BoxFit.fitHeight,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(productDataForDisplay[index][0]),
                    subtitle: Text(productDataForDisplay[index][1]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.safeBlockHorizontal * 3.5,
                        vertical: SizeConfig.safeBlockVertical * 1),
                    child: AutoSizeText(
                      productDataForDisplay[index][2].contains(".")
                          ? "Price : ${productDataForDisplay[index][2].toString()} Rs"
                          : "Price : ${productDataForDisplay[index][2].toString()}.00 Rs",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
