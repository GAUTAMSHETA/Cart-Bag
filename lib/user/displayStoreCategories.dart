import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/seller/seller_services/ProductSelectionPage.dart';
import 'package:super_market2/seller/seller_services/UpgradeProduct.dart';
import 'package:super_market2/user/displayStoreItems.dart';

class DisplayStoreCategories extends StatefulWidget {
  String storeName, storeUid;

  DisplayStoreCategories(this.storeName, this.storeUid);

  @override
  _DisplayStoreCategoriesState createState() => _DisplayStoreCategoriesState();
}

class _DisplayStoreCategoriesState extends State<DisplayStoreCategories> {
  List categoriesList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    DocumentReference userStore = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Recruiter")
        .collection(widget.storeUid)
        .doc("Product");
    DocumentReference userStore1 = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Product Categories");

    userStore.get().then((value) {
      userStore1.get().then((value1) {
        for (var i in value.data()["Categories"]) {
          categoriesList.add([i, value1.data()[i]]);
        }
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.storeName == "" ? "Select Categories" : widget.storeName,
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          widget.storeName == ""
              ? IconButton(
                  icon: Icon(Icons.edit_rounded),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => ProductSelectionPage(false)),
                    );
                  })
              : Container(),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Opacity(
                  opacity: 0.65,
                  child: Image.asset(
                    "assets/Images/Background.png",
                    height: SizeConfig.safeBlockVertical * 100,
                    width: SizeConfig.safeBlockHorizontal * 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  child: RefreshIndicator(
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: List.generate(categoriesList.length, (index) {
                        return cardGetter(index);
                      }),
                    ),
                    triggerMode: RefreshIndicatorTriggerMode.onEdge,
                    onRefresh: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(builder: (_) => super.widget),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  InkWell cardGetter(int index) {
    return InkWell(
      onTap: () {
        if (widget.storeName == "") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductSelection(categoriesList[index][0], widget.storeUid),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayStoreItems(
                  widget.storeUid, categoriesList[index][0], widget.storeName),
            ),
          );
        }
      },
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: Colors.white70,
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                categoriesList[index][1],
                height: 100,
              ),
            ),
            AutoSizeText(
              categoriesList[index][0],
              style: TextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}
