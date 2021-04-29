import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';

class SellerHistory extends StatefulWidget {
  @override
  _SellerHistoryState createState() => _SellerHistoryState();
}

class _SellerHistoryState extends State<SellerHistory> {
  final referenceDatase = FirebaseDatabase.instance;

  bool isLoading = true;

  Map<String, List> dataMap = {};

  List<Tab> getTab;
  List<Widget> getPage;

  bool noData = false;

  String todayDate = DateFormat("dd MMM yyyy").format(DateTime.now());
  String yesterdayDate = DateFormat("dd MMM yyyy")
      .format(DateTime.now().subtract(Duration(days: 1)));

  @override
  void initState() {
    _getData();
    super.initState();
  }

  Future _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNiId = prefs.getString("userNiId");

    final ref = referenceDatase
        .reference()
        .child("Super Market")
        .child("Recruiter User")
        .child(userNiId)
        .child("History");

    setState(() {
      noData = true;
    });

    ref.orderByKey().once().then((value) {
      var data = value.value;
      print(data);
      print("\n\n\n\n\n\n\n\n\n");

      if (data != null) {
        for (var i in data.keys) {
          List temp = [];
          for (var j in data[i].keys) {
            List temp1 = [];
            temp1.add(j.split(":")[2]);
            temp1.add(false);
            for (var k in data[i][j].keys) {
              List temp2 = [];
              temp2.add(k);
              for (var p in data[i][j][k].keys) {
                List temp3 = [];
                temp3.add(p);
                temp3.add(data[i][j][k][p].split(":::::")[0]);
                temp3.add(data[i][j][k][p].split(":::::")[1]);
                temp3.add(data[i][j][k][p].split(":::::")[2]);
                temp2.add(temp3);
              }
              temp1.add(temp2);
            }
            temp.add(temp1);
          }
          dataMap.addAll({i: temp});
        }

        print(dataMap);

        forRefresh();

        setState(() {
          isLoading = false;
          noData = false;
        });
      } else {
        setState(() {
          isLoading = false;
          noData = true;
        });
      }
    });
  }

  void forRefresh() {
    setState(() {
      getTab = [
        for (var i in dataMap.keys)
          Tab(
            text: i == todayDate
                ? "Today"
                : i == yesterdayDate
                    ? "Yesterday"
                    : i,
          )
      ];

      getPage = [
        for (var i in dataMap.keys) bodyView(i),
        // ForListView(i['Date'], dataMapping),
      ];
    });
  }

  Widget bodyView(String date) {
    return ListView.builder(
      itemCount: dataMap[date].length,
      itemBuilder: (BuildContext context, int position) {
        return getCard(position, date);
      },
    );
  }

  Container getCard(int index, String date) {
    int itemCount = 0;

    for (int i = 2; i < dataMap[date][index].length; i++) {
      itemCount = dataMap[date][index][i].length + itemCount - 1;
    }

    return Container(
      height:
          dataMap[date][index][1] ? SizeConfig.safeBlockVertical * 80 : null,
      child: InkWell(
        onTap: () {
          setState(() {
            dataMap[date][index][1] = !dataMap[date][index][1];
            forRefresh();
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
                      dataMap[date][index][0],
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
                dataMap[date][index][1]
                    ? SizedBox(
                        height: SizeConfig.safeBlockVertical * 2,
                      )
                    : Container(),
                dataMap[date][index][1]
                    ? Container(
                        height: SizeConfig.safeBlockVertical * 65,
                        child: ListView.builder(
                          itemCount: dataMap[date][index].length - 2,
                          itemBuilder: (BuildContext context, int position) {
                            return Column(
                              children: [
                                Center(
                                  child: AutoSizeText(
                                    dataMap[date][index][position + 2][0],
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
                                  children: dataMap[date][index][position + 2]
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
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: AutoSizeText(alarm[0]),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Center(
                                            child: AutoSizeText(alarm[1]),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Center(
                                            child: AutoSizeText(
                                                alarm[2] == "Not Available"
                                                    ? "    Not \nAvailable"
                                                    : alarm[2]),
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: dataMap.length,
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText("History",style: TextStyle(color: Colors.black),),
          bottom: isLoading
              ? null
              : TabBar(
                  isScrollable: true,
                  tabs: getTab,
                ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        drawer: Drower(recruiter: true),
        backgroundColor: Colors.grey[200],
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : noData
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
                : TabBarView(
                    physics: BouncingScrollPhysics(),
                    children: getPage,
                  ),
      ),
    );
  }
}
