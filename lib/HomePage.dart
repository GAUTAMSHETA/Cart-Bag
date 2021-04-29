import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/LogPages/LogIn.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/user/displayStoreCategories.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position _currentLocation;
  var cLat;
  var cLong;

  var select = "Home";
  bool isSearching = false;
  bool isLoading = true;

  List storeLocationList = [];
  List storeLocationListWithDistance = [];
  List searchList = [];
  List searchListForDispaly = [];
  Map storNameList = {};

  final referenceDatase = FirebaseDatabase.instance;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _checkMamu();
    _getCurrentLocation();
  }

  Future _checkMamu() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userNiId = prefs.getString("userNiId");

    referenceDatase
        .reference()
        .child("Super Market")
        .child("Simple User/${userNiId}/Personal Data")
        .orderByKey()
        .once()
        .then((DataSnapshot snapshot) async {
      var data = snapshot.value;
      if (data["Mamu Banavi Gaya"] != null) {
        if (int.tryParse(data["Mamu Banavi Gaya"]) >= 10) {
          try {
            prefs.remove("email");
            prefs.remove("userNiId");
            prefs.remove("userPhotoUrl");
            prefs.remove("userName");
            prefs.remove("recruiters");
            await FirebaseAuth.instance.signOut().then((value) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => LogInPage()),
                  ModalRoute.withName('/'));
            });
          } catch (e) {
            print(e.toString());
          }
        }
      }
    });
  }

  void _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(
      forceAndroidLocationManager: false,
    ).then((position) {
      print(position);
      setState(() {
        _currentLocation = position;
        cLat = position.latitude;
        cLong = position.longitude;
      });
    }).then((value) {
      DocumentReference userStore =
          FirebaseFirestore.instance.collection('Super Market').doc("Store");

      userStore.get().then((value) {
        storeLocationList = List.from(value.data()["store uid"]);
        searchList = List.from(value.data()["search"]);
        storNameList = value.data()["Store name"];
      }).then((value) async {
        for (String i in storeLocationList) {
          List temp = i.split(":");
          LatLng storeCoordinates =
              LatLng(double.tryParse(temp[0]), double.tryParse(temp[1]));

          double dd = await _coordinateDistance(
              _currentLocation.latitude,
              _currentLocation.longitude,
              storeCoordinates.latitude,
              storeCoordinates.longitude);

          if (dd <= 50.00) {
            storeLocationListWithDistance.add([dd, i.replaceAll(".", "#")]);
          }
        }
        setState(() {
          storeLocationListWithDistance.sort((a, b) => a[0].compareTo(b[0]));
          isLoading = false;
        });
      });
    });
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: !isSearching
            ? Text(
                "Cart Bag",
                style: TextStyle(
                  color: Colors.black,
                ),
              )
            : TextFormField(
                onChanged: (value) {
                  searchListForDispaly.clear();
                  setState(() {
                    for (String i in searchList) {
                      if (RegExp(".*${value.toUpperCase()}.*")
                          .hasMatch(i.toUpperCase())) {
                        searchListForDispaly.add(i);
                      }
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                    color: Colors.black,
                  ),
                  icon: Icon(
                    Icons.search,
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
        actions: [
          !isSearching
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WordInProgress()),
                    );
                  },
                  icon: Icon(Icons.share_rounded),
                )
              : Container(),
          IconButton(
            icon:
                !isSearching ? Icon(Icons.search) : Icon(Icons.cancel_outlined),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
          ),
          !isSearching
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WordInProgress()),
                    );
                  },
                  icon: Icon(Icons.more_vert),
                )
              : Container(),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: !isSearching ? Drower(recruiter: false) : null,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Container(
                  child: ListView.builder(
                    itemCount: storeLocationListWithDistance.length,
                    itemBuilder: (BuildContext context, int position) {
                      return cardGetter(position);
                    },
                  ),
                ),
                searchListForDispaly.length == 0 || !isSearching
                    ? Container()
                    : Container(
                        height: SizeConfig.safeBlockVertical *
                                    searchListForDispaly.length *
                                    7 <
                                SizeConfig.safeBlockVertical * 50
                            ? SizeConfig.safeBlockVertical *
                                searchListForDispaly.length *
                                7
                            : SizeConfig.safeBlockVertical * 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            border: Border.all(color: Colors.black)),
                        child: ListView.separated(
                          itemCount: searchListForDispaly.length,
                          itemBuilder: (BuildContext context, int position) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DisplayStoreCategories(
                                            searchListForDispaly[position]
                                                .split(":")[0]
                                                .split(",")[0],
                                            searchListForDispaly[position]
                                                .split(":")[1]),
                                  ),
                                );
                              },
                              child: Center(
                                heightFactor: 1.5,
                                child: AutoSizeText(
                                  searchListForDispaly[position].split(":")[0],
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.safeBlockVertical * 2),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                            color: Colors.black,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  Widget cardGetter(int index) {
    return GestureDetector(
      onTap: () {
        if (storNameList[storeLocationListWithDistance[index][1]][5]) {
          if (_closeOrNot(
              storNameList[storeLocationListWithDistance[index][1]][4])) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DisplayStoreCategories(
                      storNameList[storeLocationListWithDistance[index][1]][0],
                      storNameList[storeLocationListWithDistance[index][1]]
                          [2])),
            );
          } else {
            showSnackbar("Shop is Closed");
          }
        } else {
          showSnackbar("Shop is Closed");
        }
      },
      child: Card(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: SizeConfig.safeBlockVertical * 17,
              width: SizeConfig.safeBlockHorizontal * 35,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: Colors.grey[200],
              child: Image.network(
                storNameList[storeLocationListWithDistance[index][1]][3],
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                        storNameList[storeLocationListWithDistance[index][1]]
                            [0]),
                    subtitle: Text(
                        storNameList[storeLocationListWithDistance[index][1]]
                            [1]),
                  ),
                  ListTile(
                    title: Text(
                      storNameList[storeLocationListWithDistance[index][1]][5]
                          ? _closeOrNot(storNameList[
                                  storeLocationListWithDistance[index][1]][4])
                              ? "${storNameList[storeLocationListWithDistance[index][1]][4].replaceAll("/", " - ")}"
                              : "Closed"
                          : "Closed",
                      style: TextStyle(
                          color: storNameList[
                                  storeLocationListWithDistance[index][1]][5]
                              ? _closeOrNot(storNameList[
                                      storeLocationListWithDistance[index]
                                          [1]][4])
                                  ? null
                                  : Colors.red
                              : Colors.red),
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

  bool _closeOrNot(String _string) {
    TimeOfDay timeOfDay = TimeOfDay.now();

    TimeOfDay startTimeOfDay;
    TimeOfDay closeTimeOfDay;

    if (_string.split("/")[0].split(" ")[1] == "AM") {
      startTimeOfDay = TimeOfDay(
        hour: int.tryParse(_string.split("/")[0].split(" ")[0].split(":")[0]),
        minute: int.tryParse(_string.split("/")[0].split(" ")[0].split(":")[1]),
      );
    } else if (_string.split("/")[0].split(" ")[1] == "PM") {
      startTimeOfDay = TimeOfDay(
        hour: int.tryParse(_string.split("/")[0].split(" ")[0].split(":")[0]) +
            12,
        minute: int.tryParse(_string.split("/")[0].split(" ")[0].split(":")[1]),
      );
    }

    if (_string.split("/")[1].split(" ")[1] == "AM") {
      closeTimeOfDay = TimeOfDay(
        hour: int.tryParse(_string.split("/")[1].split(" ")[0].split(":")[0]),
        minute: int.tryParse(_string.split("/")[1].split(" ")[0].split(":")[1]),
      );
    } else if (_string.split("/")[1].split(" ")[1] == "PM") {
      closeTimeOfDay = TimeOfDay(
        hour: int.tryParse(_string.split("/")[1].split(" ")[0].split(":")[0]) +
            12,
        minute: int.tryParse(_string.split("/")[1].split(" ")[0].split(":")[1]),
      );
    }

    if (timeOfDay.hour >= startTimeOfDay.hour &&
        timeOfDay.hour <= closeTimeOfDay.hour) {
      if (timeOfDay.hour == closeTimeOfDay.hour) {
        if (timeOfDay.minute < closeTimeOfDay.minute) {
          return true;
        } else {
          return false;
        }
      }

      if (timeOfDay.hour == startTimeOfDay.hour) {
        if (timeOfDay.minute > startTimeOfDay.minute) {
          return true;
        } else {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
