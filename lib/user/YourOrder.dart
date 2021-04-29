import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/user/OrderMap.dart';

class YourOrder extends StatefulWidget {
  @override
  _YourOrderState createState() => _YourOrderState();
}

class _YourOrderState extends State<YourOrder> {
  bool isLoading = true;
  String data = "";
  String pData = "";
  bool isPLoading = true;

  GlobalKey globalKey = new GlobalKey();

  final referenceDatase = FirebaseDatabase.instance;

  String todayDate = DateFormat("dd MMM yyyy").format(DateTime.now());

  List dataList = [];
  List pDataList = [];

  @override
  void initState() {
    super.initState();
    _getData();
    _getPData();
  }

  Future _getPData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNiId = prefs.getString("userNiId");
    String userNuNam = prefs.getString("userName");

    final ref = referenceDatase
        .reference()
        .child("Super Market")
        .child("Simple User")
        .child(userNiId);

    ref
        .child("Pak Thay Gaya")
        .orderByKey()
        .once()
        .then((DataSnapshot snapshot) {
      print(snapshot.value);
      var data = snapshot.value;

      if (data != null) {
        for (var i in data.keys) {
          List temp1 = [];

          for (var j in data[i].keys) {
            if (j == todayDate) {
              temp1.add(i.split(":")[2]);
              temp1.add("${i.split(":")[0]}:${i.split(":")[1]}/${j}");
              temp1.add(false);
              List temp2 = [];
              for (var k in data[i][j].keys) {
                for (var p in data[i][j][k].keys) {
                  List temp3 = [];
                  temp3.add(data[i][j][k][p].split(":::::")[2]);
                  temp3.add(p);
                  temp3.add(k);
                  temp3.add(data[i][j][k][p].split(":::::")[0]);
                  temp3.add(data[i][j][k][p].split(":::::")[1]);
                  temp2.add(temp3);
                }
              }
              temp1.add(temp2);
              pDataList.add(temp1);
            } else {
              referenceDatase
                  .reference()
                  .child("Super Market")
                  .child("Simple User")
                  .child(userNiId)
                  .child("Pak Thay Gaya")
                  .child(i)
                  .child(j)
                  .remove();
            }
          }
        }
      } else {
        setState(() {
          isPLoading = false;
          pData = "No Data";
        });
      }
      print("Pek Thay gaya\n\n\n");
      print(pDataList);
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNiId = prefs.getString("userNiId");
    String userNuNam = prefs.getString("userName");

    final ref = referenceDatase
        .reference()
        .child("Super Market")
        .child("Simple User")
        .child(userNiId);

    ref.child("Ur Order").orderByKey().once().then((DataSnapshot snapshot) {
      print(snapshot);
      print(snapshot.value);
      // print(snapshot.value.keys);

      if (snapshot.value != null) {
        for (var i in snapshot.value.keys) {
          for (var j in snapshot.value[i].keys) {
            List temp2 = [];
            if (j == todayDate) {
              temp2.add(i.split(":")[2]);
              temp2.add("${i.split(":")[0]}:${i.split(":")[1]}/$j");
              temp2.add(false);
              List temp3 = [];
              for (var k in snapshot.value[i][j].keys) {
                temp3.add([
                  snapshot.value[i][j][k].split(":::::")[1],
                  k.split(":")[1],
                  k.split(":")[0],
                  snapshot.value[i][j][k].split(":::::")[0]
                ]);
              }
              temp2.add(temp3);
              dataList.add(temp2);
            } else {
              referenceDatase
                  .reference()
                  .child("Super Market")
                  .child("Simple User")
                  .child(userNiId)
                  .child("Ur Order")
                  .child(i)
                  .child(j)
                  .remove();
              referenceDatase
                  .reference()
                  .child("Super Market")
                  .child("Recruiter User")
                  .child(i.split(":")[0])
                  .child("Ur Order")
                  .child("${i.split(":")[0]}:${i.split(":")[1]}:$userNuNam")
                  .child(j)
                  .remove();
            }
          }
        }
      } else {
        setState(() {
          isLoading = false;
          data = "No Data";
        });
      }
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            "Your Order",
            style: TextStyle(color: Colors.black),
          ),
          bottom: isLoading
              ? null
              : TabBar(
                  tabs: [
                    Tab(
                      text: "Un-Received",
                    ),
                    Tab(text: "Ready To Receive")
                  ],
                ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        drawer: Drower(recruiter: false),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  _pendingOrder(),
                  _packedOrder(),
                ],
              ),
      ),
    );
  }

  Widget _pendingOrder() {
    return data == ""
        ? dataList == []
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
            : RefreshIndicator(
                child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: dataList.length,
                    itemBuilder: (BuildContext context, int position) {
                      return _getCard(position);
                    }),
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
          );
  }

  InkWell _getCard(int index) {
    return InkWell(
      onTap: () {
        print(dataList[index][2]);

        setState(() {
          dataList[index][2] = !dataList[index][2];
        });
        print(dataList[index][2]);
      },
      onLongPress: () {
        _showMyDialogForDelete(dataList[index][1], dataList[index][0]);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    dataList[index][0],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      _showMyDialog(context, dataList[index][1]);
                    },
                    child: Icon(
                      Icons.qr_code,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderMap(dataList[index][0],
                              dataList[index][1].split(":")[0]),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.safeBlockVertical * 2),
              Opacity(
                opacity: dataList[index][2] ? 1.0 : 0.5,
                child: dataList[index][2]
                    ? Container(
                        height: dataList[index][3].length <= 3
                            ? SizeConfig.safeBlockVertical *
                                20 *
                                dataList[index][3].length
                            : SizeConfig.safeBlockVertical * 20 * 3,
                        child: ListView.separated(
                          itemCount: dataList[index][3].length,
                          itemBuilder: (BuildContext context, int position) {
                            return Row(
                              children: [
                                Container(
                                  height: SizeConfig.safeBlockVertical * 21,
                                  width: SizeConfig.safeBlockHorizontal * 35,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Image.network(
                                    dataList[index][3][position][0],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: AutoSizeText(
                                            dataList[index][3][position][1]),
                                        subtitle: AutoSizeText(
                                            dataList[index][3][position][2]),
                                      ),
                                      ListTile(
                                        title: AutoSizeText(
                                            "Quantity : ${dataList[index][3][position][3]}"),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(
                            color: Colors.deepPurple,
                            thickness: 1,
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            height: SizeConfig.safeBlockVertical * 21,
                            width: SizeConfig.safeBlockHorizontal * 35,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Image.network(
                              dataList[index][3][0][0],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                ListTile(
                                  title: AutoSizeText(dataList[index][3][0][1]),
                                  subtitle:
                                      AutoSizeText(dataList[index][3][0][2]),
                                ),
                                ListTile(
                                  title: AutoSizeText(
                                      "Quantity : ${dataList[index][3][0][3]}"),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialogForDelete(String dK, String sN) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert Dialog'),
          content: Text('Are you sure you want to remove your Order ?'),
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
                _deleteYourProduct(dK, sN);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future _deleteYourProduct(String qr, String storeName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNuNam = prefs.getString("userName");

    print("\n\n\n");
    print(qr);

    referenceDatase
        .reference()
        .child("Super Market")
        .child("Simple User")
        .child(qr.split("/")[0].split(":")[1])
        .child("Ur Order")
        .child("${qr.split("/")[0]}:${storeName}")
        .child(qr.split("/")[1])
        .remove()
        .then((value) {
      referenceDatase
          .reference()
          .child("Super Market")
          .child("Recruiter User")
          .child(qr.split("/")[0].split(":")[0])
          .child("Ur Order")
          .child("${qr.split("/")[0]}:$userNuNam")
          .child(qr.split("/")[1])
          .remove()
          .then((value) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => super.widget),
        );
      });
    });
  }

  Widget _packedOrder() {
    return pData == ""
        ? pDataList == []
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
                      ..color = Colors.white54,
                  ),
                ),
              )
            : RefreshIndicator(
                child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: pDataList.length,
                    itemBuilder: (BuildContext context, int position) {
                      return _getPCard(position);
                    }),
                triggerMode: RefreshIndicatorTriggerMode.onEdge,
                onRefresh: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => super.widget),
                  );
                },
              )
        : Center(
            child: Text(
              pData,
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
          );
  }

  InkWell _getPCard(int index) {
    return InkWell(
      onTap: () {
        print(pDataList[index][2]);

        setState(() {
          pDataList[index][2] = !pDataList[index][2];
        });
        print(pDataList[index][2]);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    pDataList[index][0],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      _showMyDialog(context, pDataList[index][1]);
                    },
                    child: Icon(
                      Icons.qr_code,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderMap(pDataList[index][0],
                              pDataList[index][1].split(":")[0]),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.safeBlockVertical * 2),
              Opacity(
                opacity: pDataList[index][2] ? 1.0 : 0.5,
                child: pDataList[index][2]
                    ? Container(
                        height: pDataList[index][3].length <= 3
                            ? SizeConfig.safeBlockVertical *
                                20 *
                                pDataList[index][3].length
                            : SizeConfig.safeBlockVertical * 20 * 3,
                        child: ListView.separated(
                          itemCount: pDataList[index][3].length,
                          itemBuilder: (BuildContext context, int position) {
                            return Row(
                              children: [
                                Container(
                                  width: 120,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Image.network(
                                    pDataList[index][3][position][0],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: AutoSizeText(
                                            pDataList[index][3][position][1]),
                                        subtitle: AutoSizeText(
                                            pDataList[index][3][position][2]),
                                      ),
                                      ListTile(
                                        title: AutoSizeText(
                                            "Quantity : ${pDataList[index][3][position][3]}"),
                                        subtitle: AutoSizeText(
                                          pDataList[index][3][position][4],
                                          style: TextStyle(
                                            color: pDataList[index][3][position]
                                                        [4] ==
                                                    "Available"
                                                ? null
                                                : Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                            color: Colors.deepPurple,
                            height: 20.0,
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            width: 120,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Image.network(
                              pDataList[index][3][0][0],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                ListTile(
                                  title:
                                      AutoSizeText(pDataList[index][3][0][1]),
                                  subtitle:
                                      AutoSizeText(pDataList[index][3][0][2]),
                                ),
                                ListTile(
                                  title: AutoSizeText(
                                      "Quantity : ${pDataList[index][3][0][3]}"),
                                  subtitle: AutoSizeText(
                                    pDataList[index][3][0][4],
                                    style: TextStyle(
                                      color: pDataList[index][3][0][4] ==
                                              "Available"
                                          ? null
                                          : Colors.red,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context, String text) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'QR Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    repaintBoundary(text),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton.icon(
                          icon: Icon(Icons.share),
                          label: Text(
                            'Share',
                          ),
                          color: Colors.yellow[400],
                          onPressed: () {
                            _captureAndSharePng();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  RepaintBoundary repaintBoundary(String text) {
    return RepaintBoundary(
      key: globalKey,
      child: QrImage(
        data: text,
        size: SizeConfig.safeBlockHorizontal * 70,
        backgroundColor: Colors.white,
        errorStateBuilder: (cxt, err) {
          return Container(
            child: Center(
              child: Text(
                "${err.toString()} gautam",
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        // embeddedImage: ImageProvider,
      ),
    );
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();

      if (boundary.debugNeedsPaint) {
        Timer(Duration(seconds: 1), () => _captureAndSharePng());
        return null;
      }

      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      final RenderBox box = context.findRenderObject();
      Share.shareFiles([file.path],
          subject: "subject",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } catch (e) {
      print(e.toString());
    }
  }
}
