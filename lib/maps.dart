import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';

class MyMaps extends StatefulWidget {
  @override
  _MyMapsState createState() => _MyMapsState();
}

class _MyMapsState extends State<MyMaps> {
  // Initial location of the Map view
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

  // For controlling the view of the Map
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();

  // For storing the current position
  Position _currentPosition;

  LatLng _storePosition;

  Set<Marker> markers = {};

  final storeNameController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Map storNameList = {};

  List latLogList = [];
  List nameList = [];
  List addressList = [];
  List uidList = [];
  List imageList = [];
  List<String> forsearch = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((value) {
      DocumentReference userStore =
          FirebaseFirestore.instance.collection('Super Market').doc("Store");

      userStore.get().then((value) {
        storNameList = value.data()["Store name"];
      }).then((value) {
        print("\n\n");
        print(storNameList);
        print("\n\n");
        for (var i in storNameList.keys) {
          double lat = double.tryParse(i.split(":")[0].replaceAll("#", "."));
          double log = double.tryParse(i.split(":")[1].replaceAll("#", "."));
          latLogList.add([lat, log]);
          nameList.add(storNameList[i][0]);
          addressList.add(storNameList[i][1]);
          uidList.add(storNameList[i][2]);
          imageList.add(storNameList[i][3]);
          forsearch.add(storNameList[i][0].toUpperCase());
        }
        print("\n\n");
        print(latLogList);
        print(nameList);
        print(addressList);
        print(uidList);
        print(imageList);
        print("\n\n\n");
        for (int i = 0; i < nameList.length; i++) {
          setState(() {
            markers.add(
              Marker(
                markerId: MarkerId('${latLogList[i].toString()}'),
                position: LatLng(latLogList[i][0], latLogList[i][1]),
                infoWindow: InfoWindow(
                  title: nameList[i],
                  snippet: addressList[i],
                  onTap: () async {},
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          });
        }
      });
    });
  }

  Future _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;
        _storePosition = LatLng(position.latitude, position.longitude);

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId('${_currentPosition}'),
            position:
                LatLng(_currentPosition.latitude, _currentPosition.longitude),
            infoWindow: InfoWindow(
              onTap: () async {},
            ),
            icon: BitmapDescriptor.defaultMarker,
            visible: false,
          ),
        );
      });
      // await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  int countOccurrencesUsingLoop(List<String> list, String element) {
    if (list == null || list.isEmpty) {
      return 0;
    }

    int count = 0;
    for (int i = 0; i < list.length; i++) {
      if (RegExp(".*${element.toUpperCase()}.*").hasMatch(list[i])) {
        count++;
      }
    }

    return count;
  }

  Future<int> _showMyDialog(BuildContext context) async {
    List tempList = [];

    for (int i = 0; i < forsearch.length; i++) {
      if (RegExp(".*${storeNameController.text.toUpperCase()}.*")
          .hasMatch(forsearch[i])) {
        tempList.add([i, addressList[i]]);
      }
    }

    return showDialog<int>(
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
                      storeNameController.text,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: tempList.length == 1
                          ? 100
                          : tempList.length == 2
                              ? 200
                              : 300,
                      child: ListView.separated(
                        itemCount: tempList.length,
                        itemBuilder: (BuildContext context, int position) {
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context, tempList[position][0]);
                            },
                            child: AutoSizeText(
                              tempList[position][1],
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          color: Colors.black,
                          height: 20.0,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
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

  void _getCoordinates(String address) async {
    try {
      if (storeNameController.text != "") {
        int c = countOccurrencesUsingLoop(forsearch, storeNameController.text);
        print("\n\n\n\n\n\n\n\n\n$c");
        print(forsearch);
        int index;
        if (c == 1) {
          for (var k in forsearch) {
            if (RegExp(".*${storeNameController.text.toUpperCase()}.*")
                .hasMatch(k)) {
              index = forsearch.indexOf(k.toUpperCase());
            }
          }
          _storePosition = LatLng(latLogList[index][0], latLogList[index][1]);
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _storePosition,
                zoom: 18.0,
              ),
            ),
          );
        } else if (c > 1) {
          _showMyDialog(context).then((value) {
            if (value != null) {
              _storePosition =
                  LatLng(latLogList[value][0], latLogList[value][1]);
              mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _storePosition,
                    zoom: 18.0,
                  ),
                ),
              );
            }
          });
        } else if (c == 0) {
          showSnackbar("No such supermarket registered in our server!");
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Widget _textField({
    TextEditingController controller,
    String label,
    String hint,
    String initialValue,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      margin: EdgeInsets.only(
        top: SizeConfig.safeBlockHorizontal * 2,
      ),
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        // initialValue: initialValue,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AutoSizeText(
          "Location",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drower(recruiter: false),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: markers != null ? Set<Marker>.from(markers) : null,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ClipOval(
                child: Material(
                  color: Colors.orange[100], // button color
                  child: InkWell(
                    splashColor: Colors.orange, // inkwell color
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.my_location),
                    ),
                    onTap: () {
                      mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(_currentPosition.latitude,
                                _currentPosition.longitude),
                            zoom: 18.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                    child: Material(
                      color: Colors.blue[100], // button color
                      child: InkWell(
                        splashColor: Colors.blue, // inkwell color
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.add),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ClipOval(
                    child: Material(
                      color: Colors.blue[100], // button color
                      child: InkWell(
                        splashColor: Colors.blue, // inkwell color
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.remove),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: _textField(
                        label: 'Store Name',
                        hint: 'Store Name',
                        initialValue: "_currentAddress",
                        prefixIcon: Icon(Icons.store_mall_directory),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.my_location),
                          onPressed: () {
                            mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: _storePosition,
                                  zoom: 18.0,
                                ),
                              ),
                            );
                          },
                        ),
                        controller: storeNameController,
                        width: SizeConfig.screenWidth,
                        locationCallback: (String value) {
                          setState(() {});
                        }),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.safeBlockHorizontal * 2,
                      vertical: SizeConfig.safeBlockVertical * 1),
                  margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.safeBlockHorizontal * 2,
                      vertical: SizeConfig.safeBlockVertical * 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.red,
                  ),
                  child: InkWell(
                    splashColor: Colors.blue, // inkwell color
                    child: SizedBox(
                      child: Text(
                        'Get Location'.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await _getCoordinates(storeNameController.text);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
