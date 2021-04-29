import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/user/models/CardData.dart';
import 'package:super_market2/user/utils/card_data_helper.dart';

import '../displayStoreCategories.dart';

class DisplayProduct extends StatefulWidget {
  String productType;
  String storeUid;
  String storeName;
  List productData;

  DisplayProduct(
      this.productType, this.storeUid, this.storeName, this.productData);

  @override
  _DisplayProductState createState() => _DisplayProductState();
}

class _DisplayProductState extends State<DisplayProduct> {
  PageController pageController = PageController(initialPage: 0);

  String todayDate = DateFormat("dd MMM yyyy").format(DateTime.now());

  CardDataDatabaseHelper cardDataDatabaseHelper = CardDataDatabaseHelper();

  int count = 0;

  int iiDD;

  @override
  void initState() {
    cardDataDatabaseHelper
        .getCardDataMapListForCheckItems(
            "${widget.storeName}:${widget.storeUid}",
            todayDate,
            widget.productType,
            widget.productData[0])
        .then((value) {
      print(value);
      setState(() {
        if (value.length == 0) {
          iiDD = -1;
        } else {
          iiDD = value[0]["Id"];
          count = value[0]["Quantity"];
        }
      });
      print(iiDD);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.productType,
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      drawer: Drower(recruiter: false),
      body: ListView(
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 2,
                vertical: SizeConfig.safeBlockVertical * 1),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            height: SizeConfig.safeBlockVertical * 40,
            width: SizeConfig.safeBlockHorizontal * 100,
            child: Center(
              child: PageView.builder(
                pageSnapping: true,
                controller: pageController,
                itemCount: widget.productType == "Grocery" ||
                        widget.productType == "Biscuits & Cookies" ||
                        widget.productType == "Fruits & Vegetables" ||
                        widget.productType == "Dairy & Bakery"
                    ? widget.productData[6].length
                    : widget.productData[5].length,
                itemBuilder: (BuildContext context, int pos) {
                  return Image.network(
                    widget.productType == "Grocery" ||
                            widget.productType == "Biscuits & Cookies" ||
                            widget.productType == "Fruits & Vegetables" ||
                            widget.productType == "Dairy & Bakery"
                        ? widget.productData[6][pos]
                        : widget.productData[5][pos],
                    fit: BoxFit.contain,
                    // scale: 0.4,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 4,
                vertical: SizeConfig.safeBlockVertical * 1),
            child: AutoSizeText(
              widget.productData[0],
              style: TextStyle(
                fontSize: SizeConfig.safeBlockVertical * 2.8,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 10,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.safeBlockHorizontal * 4.5,
                bottom: SizeConfig.safeBlockVertical * 1),
            child: Opacity(
              opacity: 0.5,
              child: AutoSizeText(
                widget.productData[1],
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 4.5,
                vertical: SizeConfig.safeBlockVertical * 1),
            child: Row(
              children: [
                AutoSizeText(
                  "Price : ",
                  style: TextStyle(
                      fontSize: SizeConfig.safeBlockVertical * 2,
                      fontWeight: FontWeight.w500),
                ),
                AutoSizeText(
                  widget.productData[2].contains(".")
                      ? "${widget.productData[2]}  Rs"
                      : "${widget.productData[2]}.00  Rs",
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockVertical * 2,
                  ),
                ),
                Spacer(),
                widget.productType == "Grocery" ||
                        widget.productType == "Biscuits & Cookies" ||
                        widget.productType == "Fruits & Vegetables" ||
                        widget.productType == "Dairy & Bakery"
                    ? vegAndNonVeg(widget.productData[5],
                        SizeConfig.safeBlockVertical * 3.5, widget.productType)
                    : Container(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.safeBlockHorizontal * 4.5,
                bottom: SizeConfig.safeBlockVertical * 0.5),
            child: AutoSizeText(
              widget.productData[4] ? "In Stoke" : "Not In Stock",
              style: TextStyle(
                color: widget.productData[4] ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 4.5,
                vertical: SizeConfig.safeBlockVertical * 1),
            child: Row(
              children: [
                AutoSizeText(
                  "Sold by  ",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DisplayStoreCategories(
                              widget.storeName, widget.storeUid)),
                    );
                  },
                  child: AutoSizeText(
                    "${widget.storeName}",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 4.5,
                vertical: SizeConfig.safeBlockVertical * 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  "Description : ",
                  style: TextStyle(
                      fontSize: SizeConfig.safeBlockVertical * 2,
                      fontWeight: FontWeight.w500),
                ),
                AutoSizeText(
                  widget.productData[3],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 4.5,
                vertical: SizeConfig.safeBlockVertical * 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  "Qty",
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockVertical * 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.safeBlockHorizontal * 7,
                      vertical: SizeConfig.safeBlockVertical * 1),
                  margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.safeBlockHorizontal * 7,
                      vertical: SizeConfig.safeBlockVertical * 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: AutoSizeText(count.toString()),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: count <= 0
                          ? () {}
                          : () {
                              setState(() {
                                count--;
                              });

                              if (count <= 0) {
                                cardDataDatabaseHelper
                                    .deleteCardData(iiDD)
                                    .then(
                                      (value) => print("Deleted \n\n\n"),
                                    );
                              } else {
                                cardDataDatabaseHelper
                                    .updateCardData(CardData.withId(
                                        iiDD,
                                        todayDate,
                                        "${widget.storeName}:${widget.storeUid}",
                                        widget.productType,
                                        widget.productData[0],
                                        count))
                                    .then(
                                      (value) => print("Updated \n\n\n"),
                                    );
                              }
                            },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.safeBlockHorizontal * 2,
                            vertical: SizeConfig.safeBlockHorizontal * 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.horizontal_rule,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
                    InkWell(
                      onTap: () {
                        setState(() {
                          count++;
                        });

                        if (count == 1) {
                          cardDataDatabaseHelper
                              .insertCardData(CardData(
                                  todayDate,
                                  "${widget.storeName}:${widget.storeUid}",
                                  widget.productType,
                                  widget.productData[0],
                                  count))
                              .then((value) {
                            cardDataDatabaseHelper
                                .getCardDataMapListForCheckItems(
                                    "${widget.storeName}:${widget.storeUid}",
                                    todayDate,
                                    widget.productType,
                                    widget.productData[0])
                                .then((value) {
                              print(value);
                              setState(() {
                                if (value.length == 0) {
                                  iiDD = -1;
                                } else {
                                  iiDD = value[0]["Id"];
                                  count = value[0]["Quantity"];
                                }
                              });
                              print(iiDD);
                            });
                          });
                        } else {
                          cardDataDatabaseHelper
                              .updateCardData(CardData.withId(
                                  iiDD,
                                  todayDate,
                                  "${widget.storeName}:${widget.storeUid}",
                                  widget.productType,
                                  widget.productData[0],
                                  count))
                              .then(
                                (value) => print("Updated \n\n\n"),
                              );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.safeBlockHorizontal * 2,
                            vertical: SizeConfig.safeBlockHorizontal * 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
