import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';

class SellerOrder extends StatefulWidget {
  @override
  _SellerOrderState createState() => _SellerOrderState();
}

class _SellerOrderState extends State<SellerOrder> {
  final referenceDatase = FirebaseDatabase.instance;

  List dataList = [];

  bool isLoading = true;

  String storName;
  String emptyData = "";

  String todayDate = DateFormat("dd MMM yyyy").format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "Your Order",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      drawer: Drower(recruiter: true),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : emptyData == ""
              ? buildListView()
              : Center(
                  child: Text(
                    emptyData,
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

  RefreshIndicator buildListView() {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => super.widget),
        );
      },
      child: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (BuildContext context, int position) {
          return Dismissible(
            key: Key(dataList[position][1].toString()),
            child: getCard(position),
            onDismissed: (value) {
              print("\n\n\nRemoved\n\n\n");
              placeOrder(dataList[position]);
              dataList.remove(dataList[position]);
            },
          );
        },
      ),
    );
  }

  void placeOrder(List orderList) async {
    print(orderList);

    final ref1 = referenceDatase
        .reference()
        .child("Super Market")
        .child("Recruiter User")
        .child(orderList[1].split(":")[0])
        .child("Pak Thay Gaya");

    final ref2 = referenceDatase
        .reference()
        .child("Super Market")
        .child("Simple User")
        .child(orderList[1].split(":")[1].split("/")[0])
        .child("Pak Thay Gaya");

    await sendMail(orderList[1].split(":")[1].split("/")[0], orderList);

    for (var v = 3; v < orderList.length; v++) {
      for (var j = 1; j < orderList[v].length; j++) {
        ref1.update({
          "${orderList[1].split("/")[0]}:${orderList[0]}/$todayDate/${orderList[v][0]}/${orderList[v][j][0]}":
              "${orderList[v][j][1]}:::::${orderList[v][j][2]}:::::${orderList[v][j][3]}",
        });
      }
    }

    for (var v = 3; v < orderList.length; v++) {
      for (var j = 1; j < orderList[v].length; j++) {
        ref2.update({
          "${orderList[1].split("/")[0]}:${storName}/$todayDate/${orderList[v][0]}/${orderList[v][j][0]}":
              "${orderList[v][j][1]}:::::${orderList[v][j][2]}:::::${orderList[v][j][3]}",
        });
      }
    }

    referenceDatase
        .reference()
        .child("Super Market")
        .child("Simple User")
        .child(orderList[1].split(":")[1].split("/")[0])
        .child("Ur Order")
        .child("${orderList[1].split("/")[0]}:${storName}")
        .child(orderList[1].split("/")[1])
        .remove()
        .then((value) {
      referenceDatase
          .reference()
          .child("Super Market")
          .child("Recruiter User")
          .child(orderList[1].split(":")[0])
          .child("Ur Order")
          .child("${orderList[1].split("/")[0]}:${orderList[0]}")
          .child(orderList[1].split("/")[1])
          .remove()
          .then((value) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => super.widget),
        );
      });
    });
  }

  Future sendMail(String uid, List orderList) async {
    String username = "app.supermarket2022@gmail.com"; //Your Email;
    String password = "de@sm2022"; //Your Email's password;

    String textForSend =
        "Hiii ${orderList[0]} Your Order is ready \nPlease get your order from $storName within one hour\n\n";

    String tableForSend = """<html> 
                              <head>  
                                <style> 
                                  table, th, td { border: 2px solid black; border-collapse: collapse; } 
                                   td { padding: 5px; text-align: center;  } 
                                   th { text-align: center; } 
                                </style> 
                              </head>
                              <body> 
                                <p>Hiii ${orderList[0]} Your Order is ready for the following products. 
                                \nPlease get your order from $storName within one hour</p> 
                                <table> 
                                  <tr> 
                                    <th>Product Name</th> 
                                    <th>Quantity</th> 
                                    <th>Availability</th> 
                                  </tr> """;

    textForSend = textForSend + "Availability\tQuantity\t\t\t\tProduct Name\n";

    for (int i = 3; i < orderList.length; i++) {
      for (int j = 1; j < orderList[i].length; j++) {
        if (orderList[i][j][2] == "Available") {
          tableForSend = tableForSend +
              """<tr> 
               <td>${orderList[i][j][0]}</td> 
                 <td>${orderList[i][j][1]}</td> 
                 <td>${orderList[i][j][2]}</td> 
                </tr> """;
        } else {
          tableForSend = tableForSend +
              """<tr> 
               <td>${orderList[i][j][0]}</td> 
                 <td>${orderList[i][j][1]}</td> 
                 <td style='color:red'>${orderList[i][j][2]}</td> 
                </tr> """;
        }
      }
    }

    tableForSend = tableForSend +
        """</table> 
        <p>Thank you for shopping from ${storName}. we are looking forward to connect with you in future for further shopping.</p>
                                     </body> 
                                     </html>""";

    final sendEmail = await referenceDatase
        .reference()
        .child("Super Market")
        .child("Simple User")
        .child(uid)
        .child("Personal Data")
        .child("email")
        .orderByKey()
        .once()
        .then((value) async {
      final smtpServer = gmail(username, password);
      // Creating the Gmail server

      // Create our email message.
      final message = Message()
        ..from = Address(username)
        ..recipients.add(value.value) //recipent email
        ..subject = "Text mail for Super Market App" //subject of the email
        ..html = tableForSend; //body of the email

      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' +
            sendReport.toString()); //print if the email is sent
      } on MailerException catch (e) {
        print('Message not sent. \n' +
            e.toString()); //print if the email is not sent
      }
    });
  }

  Container getCard(int index) {
    int itemCount = 0;

    for (int i = 3; i < dataList[index].length; i++) {
      itemCount = dataList[index][i].length + itemCount - 1;
    }

    return Container(
      height: dataList[index][2] ? SizeConfig.safeBlockVertical * 80 : null,
      child: InkWell(
        onTap: () {
          setState(() {
            dataList[index][2] = !dataList[index][2];
          });
        },
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 2,
                vertical: SizeConfig.safeBlockVertical * 2),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      dataList[index][0],
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockVertical * 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AutoSizeText(
                      "Items : $itemCount",
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockVertical * 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                dataList[index][2]
                    ? SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                      )
                    : Container(),
                dataList[index][2]
                    ? Container(
                        height: SizeConfig.safeBlockVertical * 65,
                        child: ListView.builder(
                          itemCount: dataList[index].length - 3,
                          itemBuilder: (BuildContext context, int position) {
                            return Column(
                              children: [
                                Center(
                                  child: AutoSizeText(
                                    dataList[index][position + 3][0],
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.safeBlockHorizontal * 3,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: SizeConfig.safeBlockVertical * 1.6),
                                Table(
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  border: TableBorder.all(color: Colors.black),
                                  columnWidths: {
                                    0: FlexColumnWidth(4),
                                    1: FlexColumnWidth(1.5),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: dataList[index][position + 3]
                                      .map<TableRow>((alarm) {
                                    if (alarm.length != 4) {
                                      return TableRow(
                                        children: [
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Center(
                                              child: AutoSizeText(
                                                "Product Name",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Center(
                                              child: AutoSizeText(
                                                "Quantity",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: InkWell(
                                              onTap: () {
                                                print("tap");
                                              },
                                              child: Center(
                                                child: AutoSizeText(
                                                  "Availability",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return TableRow(
                                      decoration: BoxDecoration(
                                          color: alarm[2] == "Not Available"
                                              ? Colors.red[100]
                                              : Colors.white),
                                      children: [
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: InkWell(
                                            onTap: () {
                                              if (alarm[2] == "Not Available") {
                                                setState(() {
                                                  alarm[2] = "Available";
                                                });
                                              } else {
                                                setState(() {
                                                  alarm[2] = "Not Available";
                                                });
                                              }
                                            },
                                            child: Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: AutoSizeText(alarm[0]),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: InkWell(
                                            onTap: () {
                                              if (alarm[2] == "Not Available") {
                                                setState(() {
                                                  alarm[2] = "Available";
                                                });
                                              } else {
                                                setState(() {
                                                  alarm[2] = "Not Available";
                                                });
                                              }
                                            },
                                            child: Center(
                                              child: AutoSizeText(alarm[1]),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: InkWell(
                                            onTap: () {
                                              if (alarm[2] == "Not Available") {
                                                setState(() {
                                                  alarm[2] = "Available";
                                                });
                                              } else {
                                                setState(() {
                                                  alarm[2] = "Not Available";
                                                });
                                              }
                                            },
                                            child: Center(
                                              child: AutoSizeText(
                                                  alarm[2] == "Not Available"
                                                      ? "    Not \nAvailable"
                                                      : alarm[2]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                                SizedBox(
                                    height: SizeConfig.safeBlockVertical * 2),
                              ],
                            );
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _getData();

    super.initState();
  }

  void _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNiId = prefs.getString("userNiId");
    String userNuNam = prefs.getString("userName");

    final ref = referenceDatase
        .reference()
        .child("Super Market")
        .child("Recruiter User")
        .child(userNiId);

    final ref2 = referenceDatase
        .reference()
        .child("Super Market")
        .child("Recruiter User")
        .child(userNiId)
        .child("Personal Data")
        .child("store name");

    ref2.orderByKey().once().then((value) {
      setState(() {
        storName = value.value;
      });
    });

    ref.child("Ur Order").orderByKey().once().then((DataSnapshot snapshot) {
      print(snapshot.value);

      var data = snapshot.value;

      if (data != null) {
        for (var i in data.keys) {
          print(i);

          for (var j in data[i].keys) {
            print(j);
            List temp1 = [];
            if (j == todayDate) {
              temp1.add(i.split(":")[2]);
              temp1.add("${i.split(":")[0]}:${i.split(":")[1]}/$j");
              temp1.add(false);

              for (var k in data[i][j].keys) {
                print(k);
                List temp2 = [];
                temp2.add(k);
                for (var p in data[i][j][k].keys) {
                  print(p);
                  print(data[i][j][k][p]);
                  List temp3 = [];
                  temp3.add(p);
                  temp3.add(data[i][j][k][p].split(":::::")[0]);
                  temp3.add("Available");
                  temp3.add(data[i][j][k][p].split(":::::")[1]);
                  temp2.add(temp3);
                }
                temp1.add(temp2);
              }
              dataList.add(temp1);
            } else {
              referenceDatase
                  .reference()
                  .child("Super Market")
                  .child("Simple User")
                  .child(i.split(":")[1])
                  .child("Ur Order")
                  .child("${i.split(":")[0]}:${i.split(":")[1]}:$storName")
                  .child(j)
                  .remove();
              referenceDatase
                  .reference()
                  .child("Super Market")
                  .child("Recruiter User")
                  .child(i.split(":")[0])
                  .child("Ur Order")
                  .child(i)
                  .child(j)
                  .remove();
            }
          }
        }
      } else {
        setState(() {
          emptyData = "No Data";
        });
      }
      print("\n\n");
      print(dataList);
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }
}
