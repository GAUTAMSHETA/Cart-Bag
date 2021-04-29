import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderMap extends StatefulWidget {
  String superMarketName;
  String suprerMarketUid;

  OrderMap(this.superMarketName, this.suprerMarketUid);

  @override
  _OrderMapState createState() => _OrderMapState();
}

class _OrderMapState extends State<OrderMap> {
  final referenceDatase = FirebaseDatabase.instance;

  LatLng storeLatLng;

  // Initial location of the Map view
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

  // For controlling the view of the Map
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();

  // For storing the current position
  Position _currentPosition;

  Set<Marker> markers = {};

  String storeAddress;

  @override
  void initState() {
    _getCoordinates();

    super.initState();
  }

  void _getCoordinates() {
    referenceDatase
        .reference()
        .child("Super Market")
        .child("Recruiter User")
        .child(widget.suprerMarketUid)
        .child("Personal Data")
        .orderByKey()
        .once()
        .then((value) {
          setState(() {
            storeAddress = value.value["store address"];
                  storeLatLng = LatLng(value.value["latitude"], value.value["longitude"]);
          });
      print(storeLatLng);
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId('${storeLatLng}'),
            position: LatLng(storeLatLng.latitude, storeLatLng.longitude),
            infoWindow: InfoWindow(
              title: widget.superMarketName,
              snippet: storeAddress,
              onTap: () async {},
            ),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      });
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(storeLatLng.latitude, storeLatLng.longitude),
            zoom: 18.0,
          ),
        ),
      );
    }).then((value) async {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) async {
        setState(() {
          // Store the position in the variable
          _currentPosition = position;
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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(widget.superMarketName,style: TextStyle(color: Colors.black),),
        iconTheme: IconThemeData(color: Colors.black),
      ),
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
                    onLongPress: (){
                      mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(storeLatLng.latitude,
                                storeLatLng.longitude),
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
        ],
      ),
    );
  }
}
