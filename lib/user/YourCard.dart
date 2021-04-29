import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/user/models/CardData.dart';
import 'package:super_market2/user/utils/card_data_helper.dart';
import '../SizeConfig.dart';

class YourCard extends StatefulWidget {
  @override
  _YourCardState createState() => _YourCardState();
}

class _YourCardState extends State<YourCard> {
  CardDataDatabaseHelper cardDataDatabaseHelper = CardDataDatabaseHelper();

  final referenceDatase = FirebaseDatabase.instance;

  String todayDate = DateFormat("dd MMM yyyy").format(DateTime.now());
  String yesterdayDate = DateFormat("dd MMM yyyy")
      .format(DateTime.now().subtract(Duration(days: 1)));

  List dateList = [];
  List<Tab> getTab;
  List<RefreshIndicator> getPage;

  Map dataMapping = {};
  Map imageMapping = {};
  var time;

  bool isLoading = true;
  String data = "";

  @override
  void initState() {
    cardDataDatabaseHelper.getCardDataMapListForCardDate().then((value) {
      if (value != null) {
        setState(() {
          dateList = List.from(value);
        });

        List<String> temp = [];
        for (var i in dateList) {
          temp.add(i["Date"]);
        }

        cardDataDatabaseHelper
            .getCardDataMapListForDailyCardDate(temp)
            .then((Map value) {
          print(value);

          for (var i in value.keys) {
            List tempList = [];
            for (var j in value[i]) {
              DocumentReference userStore = FirebaseFirestore.instance
                  .collection('Super Market')
                  .doc("Recruiter")
                  .collection(j['Super_Id'].split(":")[1])
                  .doc(j['Product_Categorie']);
              userStore.get().then((value1) {
                var subList = value1.data()[j['Product_Name']];
                tempList.add([
                  subList[0], //name
                  j['Super_Id'],
                  subList[2],
                  j['Quantity'],
                  subList[5]['Images'][0], // Image
                  j['Id'],
                  j["Product_Categorie"],
                ]);
                imageMapping.addAll({subList[0]: subList[5]['Images'][0]});
              });
            }

            dataMapping.addAll({i: tempList});
            print(dataMapping);
            print("\n\n\n");
          }
        }).then((value) {
          time = Timer.periodic(Duration(seconds: 3), (timer) {
            if (dataMapping.length == dateList.length) {
              setState(() {
                forRefresh();

                isLoading = false;
                if (dateList.length == 0) {
                  data = "No Data";
                }
                time.cancel();
                print(time.isActive);
              });
            }
          });
        });
      } else {
        setState(() {
          isLoading = false;
          data = "No Data";
          print("No data");
        });
      }
      print(dateList);
    });
    super.initState();
  }

  void forRefresh() {
    setState(() {
      for (var i in dataMapping.keys) {
        print(dataMapping);
        print(dataMapping[i].toString());
        if (dataMapping[i].toString() == "[]") {
          dataMapping.remove(i);
          print("map");
          for (var j in dateList) {
            if (j["Date"] == i) {
              dateList.remove(j);
              print("List");
              break;
            }
          }
          ;
          break;
        }
      }
      ;
      getTab = [
        for (var i in dateList)
          Tab(
              text: i["Date"] == todayDate
                  ? "Today"
                  : i["Date"] == yesterdayDate
                      ? "Yesterday"
                      : i["Date"]),
      ];
      print(getTab.length);
      getPage = [
        for (var i in dateList) bodyView(i['Date']),
        // ForListView(i['Date'], dataMapping),
      ];
      if (getTab.length == 0) {
        data = "NO DATA";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: dateList.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Your Cart",
            style: TextStyle(color: Colors.black),
          ),
          bottom: isLoading
              ? null
              : getTab.length == 0
                  ? null
                  : TabBar(
                      isScrollable: true,
                      tabs: getTab,
                    ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        drawer: Drower(recruiter: false),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : data == ""
                ? TabBarView(
                    physics: BouncingScrollPhysics(),
                    children: getPage,
                  )
                : Center(
                    child: Text(
                      "NO DATA",
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

  Future<void> _showMyDialog(String dK, int p) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert Dialog'),
          content: Text('Are you sure you want to remove the item ?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                print("\n\nGautam\n\n");
                cardDataDatabaseHelper
                    .deleteCardData(dataMapping[dK][p][5])
                    .then((value) {
                  setState(() {
                    dataMapping[dK].remove(dataMapping[dK][p]);
                    forRefresh();
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future _order(String dateKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNiId = prefs.getString("userNiId");
    String userNuNam = prefs.getString("userName");

    final ref = referenceDatase
        .reference()
        .child("Super Market")
        .child("Simple User")
        .child(userNiId);

    final ref2 = referenceDatase
        .reference()
        .child("Super Market")
        .child("Recruiter User");

    cardDataDatabaseHelper.getCardDataMapListForOrder(dateKey).then((value) {
      print(value);

      ref.child("Ur Order").orderByKey().once().then((DataSnapshot snapshot) {
        print(snapshot.value);
        for (var v in value.keys) {
          print(
              "${v.split(":")[1]}/${userNiId}/${DateTime.now().toString().replaceAll(":", "&")}");
          var tamp;
          if (snapshot.value != null &&
              snapshot.value[
                      "${v.split(":")[1]}:${userNiId}:${v.split(":")[0]}"] !=
                  null) {
            tamp = snapshot
                .value["${v.split(":")[1]}:${userNiId}:${v.split(":")[0]}"]
                    [todayDate]
                .keys;
          }

          for (var v2 in value[v]) {
            if (snapshot.value != null &&
                snapshot.value[
                        "${v.split(":")[1]}:${userNiId}:${v.split(":")[0]}"] !=
                    null &&
                tamp.contains("${v2.split(":")[0]}:${v2.split(":")[1]}")) {
              var tamp2 = int.tryParse(snapshot.value[
                          "${v.split(":")[1]}:${userNiId}:${v.split(":")[0]}"]
                          [todayDate]["${v2.split(":")[0]}:${v2.split(":")[1]}"]
                      .split(":")[0]) +
                  int.tryParse("${v2.split(":")[2]}");

              ref.child("Ur Order").update({
                "${v.split(":")[1]}:${userNiId}:${v.split(":")[0]}/$todayDate/${v2.split(":")[0]}:${v2.split(":")[1]}":
                    "$tamp2:::::${imageMapping[v2.split(":")[1]]}",
              });
              ref2.child(v.split(":")[1]).child("Ur Order").update({
                "${v.split(":")[1]}:${userNiId}:${userNuNam}/$todayDate/${v2.split(":")[0]}/${v2.split(":")[1]}":
                    "$tamp2:::::${imageMapping[v2.split(":")[1]]}",
              });
            } else {
              ref.child("Ur Order").update({
                "${v.split(":")[1]}:${userNiId}:${v.split(":")[0]}/$todayDate/${v2.split(":")[0]}:${v2.split(":")[1]}":
                    "${v2.split(":")[2]}:::::${imageMapping[v2.split(":")[1]]}",
              });
              ref2.child(v.split(":")[1]).child("Ur Order").update({
                "${v.split(":")[1]}:${userNiId}:${userNuNam}/$todayDate/${v2.split(":")[0]}/${v2.split(":")[1]}":
                    "${v2.split(":")[2]}:::::${imageMapping[v2.split(":")[1]]}",
              });
            }
          }
        }
      });
    }).then((value) {
      cardDataDatabaseHelper.deleteCardDataWithDate(dateKey).then((value) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => super.widget),
        );
      });
    });
  }

  RefreshIndicator bodyView(String dateKey) {
    return RefreshIndicator(
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: dataMapping[dateKey].length + 1,
        itemBuilder: (BuildContext context, int position) {
          if (position == dataMapping[dateKey].length) {
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal * 20),
              child: RaisedButton(
                onPressed: () {
                  _showMyDialogForOrder(dateKey);
                },
                child: AutoSizeText("Place Order"),
                color: Colors.yellow,
              ),
            );
          }
          return InkWell(
            onLongPress: () {
              _showMyDialog(dateKey, position);
            },
            child: Card(
              margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: SizeConfig.safeBlockVertical * 24,
                          height: SizeConfig.safeBlockVertical * 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Image.network(
                            dataMapping[dateKey][position][4],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              ListTile(
                                title: AutoSizeText(
                                    dataMapping[dateKey][position][0]),
                                subtitle: AutoSizeText(
                                  "Sold by : ${dataMapping[dateKey][position][1].split(':')[0]}",
                                ),
                              ),
                              ListTile(
                                title: AutoSizeText(dataMapping[dateKey]
                                            [position][2]
                                        .contains(".")
                                    ? "Price : ${dataMapping[dateKey][position][2].toString()} Rs"
                                    : "Price : ${dataMapping[dateKey][position][2].toString()}.00 Rs"),
                              ),
                              // Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (dataMapping[dateKey][position][3] >
                                          1) {
                                        cardDataDatabaseHelper
                                            .updateCardData(CardData.withId(
                                                dataMapping[dateKey][position]
                                                    [5],
                                                dateKey,
                                                dataMapping[dateKey][position]
                                                    [1],
                                                dataMapping[dateKey][position]
                                                    [6],
                                                dataMapping[dateKey][position]
                                                    [0],
                                                dataMapping[dateKey][position]
                                                        [3] -
                                                    1))
                                            .then((value) {
                                          setState(() {
                                            dataMapping[dateKey][position][3]--;
                                          });
                                          forRefresh();
                                        });
                                      } else {
                                        cardDataDatabaseHelper
                                            .deleteCardData(dataMapping[dateKey]
                                                [position][5])
                                            .then((value) {
                                          setState(() {
                                            dataMapping[dateKey][position][3]--;

                                            dataMapping[dateKey].remove(
                                                dataMapping[dateKey][position]);

                                            forRefresh();
                                          });
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              SizeConfig.safeBlockHorizontal *
                                                  2,
                                          vertical:
                                              SizeConfig.safeBlockHorizontal *
                                                  2),
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
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.safeBlockHorizontal * 4,
                                        vertical:
                                            SizeConfig.safeBlockVertical * 1),
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.safeBlockHorizontal * 3,
                                        vertical:
                                            SizeConfig.safeBlockVertical * 1),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: AutoSizeText(dataMapping[dateKey]
                                            [position][3]
                                        .toString()),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      cardDataDatabaseHelper
                                          .updateCardData(CardData.withId(
                                              dataMapping[dateKey][position][5],
                                              dateKey,
                                              dataMapping[dateKey][position][1],
                                              dataMapping[dateKey][position][6],
                                              dataMapping[dateKey][position][0],
                                              dataMapping[dateKey][position]
                                                      [3] +
                                                  1))
                                          .then((value) {
                                        setState(() {
                                          dataMapping[dateKey][position][3]++;
                                        });
                                        forRefresh();
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              SizeConfig.safeBlockHorizontal *
                                                  2,
                                          vertical:
                                              SizeConfig.safeBlockHorizontal *
                                                  2),
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => super.widget),
        );
      },
    );
  }

  Future<void> _showMyDialogForOrder(String dK) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert Dialog'),
          content: Text(
              'Collect your order before closing hours of respective marts.'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                print("\n\nGautam\n\n");
                _order(dK);
              },
            ),
          ],
        );
      },
    );
  }
}
