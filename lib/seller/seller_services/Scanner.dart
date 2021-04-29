import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  String qrData = "";
  final referenceDatase = FirebaseDatabase.instance;
  String customerName = "";

  String todayDate = DateFormat("dd MMM yyyy").format(DateTime.now());

  List dataList = [];

  bool isLoading = true;

  @override
  void initState() {
    _scan();

    _deleteOrder();

    super.initState();
  }

  Future _deleteOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNiId = prefs.getString("userNiId");

    referenceDatase
        .reference()
        .child("Super Market")
        .child("Recruiter User")
        .child(userNiId)
        .child("Pak Thay Gaya")
        .orderByKey()
        .once()
        .then((value) {
      var data = value.value;
      if (data != null) {
        for (var i in data.keys) {
          for (var j in data[i].keys) {
            if (j != todayDate) {
              int count = 0;
              DatabaseReference ref = referenceDatase
                  .reference()
                  .child("Super Market")
                  .child("Recruiter User")
                  .child(userNiId);

              referenceDatase
                  .reference()
                  .child("Super Market")
                  .child("Recruiter User")
                  .child(userNiId)
                  .child("Mamu Banavi Gaya")
                  .orderByKey()
                  .once()
                  .then((value2) {
                var data2 = value2.value;
                if (data2 != null && data2[i] != null) {
                  count = int.tryParse(data2[i]);
                }
              }).then((value3) {
                ref.child("Mamu Banavi Gaya").update({
                  i: (count + 1).toString(),
                }).then((value) {
                  int userCount = 0;
                  referenceDatase
                      .reference()
                      .child("Super Market")
                      .child("Simple User")
                      .child(i.split(":")[1])
                      .child("Personal Data")
                      .orderByKey()
                      .once()
                      .then((value3) {
                    var data3 = value3.value;
                    if (data3 != null && data3["Mamu Banavi Gaya"] != null) {
                      userCount = int.tryParse(data3["Mamu Banavi Gaya"]);
                      if (userCount > 8) {
                        String simpleUserId = i.split(":")[1];
                        referenceDatase
                            .reference()
                            .child("Super Market")
                            .child("Simple User")
                            .child(simpleUserId)
                            .child("Personal Data")
                            .update({
                          "Block": "Yes",
                        });
                      }
                    }
                  }).then((value) {
                    referenceDatase
                        .reference()
                        .child("Super Market")
                        .child("Simple User")
                        .child(i.split(":")[1])
                        .child("Personal Data")
                        .update({
                      "Mamu Banavi Gaya": (userCount + 1).toString(),
                    }).then((value) {
                      referenceDatase
                          .reference()
                          .child("Super Market")
                          .child("Recruiter User")
                          .child(userNiId)
                          .child("Pak Thay Gaya")
                          .child(i)
                          .child(j)
                          .remove();
                    });
                  });
                });
              });
            }
          }
        }
      }
    });
  }

  Future _scan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNiId = prefs.getString("userNiId");

    String codeSanner = await BarcodeScanner.scan(); //barcode scnner

    setState(() {
      customerName = "";
      isLoading = true;
    });

    if (codeSanner.split("/")[0].length == 57) {
      if (codeSanner.split("/")[0].split(":")[0] == userNiId) {
        if (codeSanner.split("/")[0].split(":")[0].length == 28 &&
            codeSanner.split("/")[0].split(":")[1].length == 28) {
          setState(() {
            qrData = codeSanner;
          });
          if (qrData == codeSanner) {
            dataList.clear();
            referenceDatase
                .reference()
                .child("Super Market")
                .child("Simple User")
                .child("${qrData.split("/")[0].split(":")[1]}")
                .child("Personal Data")
                .child("name")
                .orderByKey()
                .once()
                .then((value) {
              setState(() {
                customerName = value.value;
              });
            }).then((value) {
              referenceDatase
                  .reference()
                  .child("Super Market")
                  .child("Recruiter User")
                  .child(userNiId)
                  .child("Pak Thay Gaya")
                  .child("${qrData.split("/")[0]}:$customerName")
                  .child(qrData.split("/")[1])
                  .orderByKey()
                  .once()
                  .then((DataSnapshot snapshot) {
                print(snapshot.value);
                print(customerName);
                print("${qrData.split("/")[0]}:$customerName");
                print(qrData.split("/")[1]);
                print("${qrData.split("/")[0].split(":")[1]}");
                print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");

                var data = snapshot.value;
                dataList.add(customerName);
                if (data != null) {
                  for (var i in data.keys) {
                    dataList.add(i);
                    for (var j in data[i].keys) {
                      dataList.add([
                        j,
                        data[i][j].split(":::::")[0],
                        data[i][j].split(":::::")[1],
                        data[i][j].split(":::::")[2]
                      ]);
                    }
                  }
                }
                print(qrData);
                for (var k in dataList) {
                  print(k);
                }
                setState(() {
                  isLoading = false;
                });
              });
            });
          }
        } else {
          setState(() {
            qrData = "Wrong QR Code";
          });
        }
      } else {
        setState(() {
          qrData = "Wrong Shop.";
        });
      }
    } else {
      setState(() {
        qrData = "Wrong QR Code";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customerName == "" ? "Scanner" : customerName,style: TextStyle(color: Colors.black),),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner_outlined),
            onPressed: () {
              _scan();
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      drawer: Drower(recruiter: true),
      body: qrData.length < 56
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.safeBlockHorizontal * 6),
                child: Text(
                  qrData,
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
            )
          : isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : dataList.length == 1
                  ? Center(
                      child: Text(
                        "No Data",
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
                    )
                  : ListView.builder(
                      itemCount: dataList.length + 1,
                      itemBuilder: (BuildContext context, int position) {
                        if (position == 0) {
                          return Container();
                        }
                        if (dataList.length == position) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    SizeConfig.safeBlockHorizontal * 20),
                            child: RaisedButton(
                              onPressed: () {
                                _goToHistory(position);
                              },
                              child: AutoSizeText("Confirm"),
                              color: Colors.yellow[200],
                            ),
                          );
                        }
                        if (dataList[position].length == 4) {
                          return Card(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      SizeConfig.safeBlockHorizontal * 3,
                                  vertical: SizeConfig.safeBlockVertical * 1),
                              child: Row(
                                children: [
                                  Container(
                                    height: SizeConfig.safeBlockVertical * 15,
                                    width: SizeConfig.safeBlockHorizontal * 30,
                                    padding: EdgeInsets.symmetric(horizontal:10,vertical: 10),
                                    child: Image.network(
                                      dataList[position][3],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: AutoSizeText(
                                              dataList[position][0]),
                                          subtitle: AutoSizeText(
                                              "Quantity : ${dataList[position][1]}"),
                                        ),
                                        ListTile(
                                          title: AutoSizeText(
                                            dataList[position][2],
                                            style: TextStyle(
                                              color: dataList[position][2] ==
                                                      "Available"
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
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
                        return Card(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: SizeConfig.safeBlockVertical * 1),
                              child: AutoSizeText(
                                dataList[position],
                                style: TextStyle(
                                  fontSize: SizeConfig.safeBlockVertical * 2.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
    );
  }

  Future _goToHistory(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNiId = prefs.getString("userNiId");

    String superMarketName = "";

    referenceDatase
        .reference()
        .child("Super Market")
        .child("Recruiter User")
        .child(userNiId)
        .child("Personal Data")
        .child("store name")
        .orderByKey()
        .once()
        .then((MarketName) {
      setState(() {
        superMarketName = MarketName.value;
      });
    }).then((value) {
      referenceDatase
          .reference()
          .child("Super Market")
          .child("Recruiter User")
          .child(userNiId)
          .child("Pak Thay Gaya")
          .child("${qrData.split("/")[0]}:${customerName}")
          .child(qrData.split("/")[1])
          .orderByKey()
          .once()
          .then((DataSnapshot snapshot) {
        referenceDatase
            .reference()
            .child("Super Market")
            .child("Recruiter User")
            .child(userNiId)
            .child("History")
            .update({
          "${snapshot.key}/${qrData.split("/")[0]}:${customerName}":
              snapshot.value,
        }).then((value) {
          referenceDatase
              .reference()
              .child("Super Market")
              .child("Recruiter User")
              .child(userNiId)
              .child("Pak Thay Gaya")
              .child("${qrData.split("/")[0]}:${customerName}")
              .child(qrData.split("/")[1])
              .remove();
          referenceDatase
              .reference()
              .child("Super Market")
              .child("Simple User")
              .child(qrData.split("/")[0].split(":")[1])
              .child("Pak Thay Gaya")
              .child("${qrData.split("/")[0]}:${superMarketName}")
              .child(qrData.split("/")[1])
              .remove()
              .then((value) {
            referenceDatase
                .reference()
                .child("Super Market")
                .child("Simple User")
                .child(qrData.split("/")[0].split(":")[1])
                .child("History")
                .update({
              "${snapshot.key}/${qrData.split("/")[0]}:${superMarketName}":
                  snapshot.value,
            }).then((value) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => super.widget),
              );
            });
          });
        });
      });
    });
  }
}
