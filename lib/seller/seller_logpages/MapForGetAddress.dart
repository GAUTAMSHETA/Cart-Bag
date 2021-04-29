import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/seller/seller_logpages/SellerSignUp.dart';
import 'package:super_market2/service/DataProvider.dart';

class MapForGetAddress extends StatefulWidget {
  @override
  _MapForGetAddressState createState() => _MapForGetAddressState();
}

class _MapForGetAddressState extends State<MapForGetAddress> {
  // Initial location of the Map view
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

  // For controlling the view of the Map
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();

  // For storing the current position
  Position _currentPosition;
  String _currentAddress;

  String _storeAddress;
  LatLng _storePosition;

  Set<Marker> markers = {};

  final storeAddressController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
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
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddress() async {
    try {
      // Places are retrieved using the coordinates
      await Geocoder.local
          .findAddressesFromCoordinates(Coordinates(
              _currentPosition.latitude, _currentPosition.longitude))
          .then((p) {
        // Taking the most probable result
        var place = p.first;

        setState(() {
          List<String> tempAdd = place.addressLine.split(",");

          SellerPersonalData.locality = place.locality;
          SellerPersonalData.subLocality = place.subLocality;
          SellerPersonalData.state = place.adminArea;


          _currentAddress =
              "${tempAdd[2]}, ${tempAdd[0]}, ${tempAdd[1]}, ${tempAdd[3]}, ${tempAdd[4]}, ${tempAdd[5]}, ${tempAdd[6]}";

          // Update the text of the TextField
          storeAddressController.text = _currentAddress;

          // Setting the user's present location as the starting address
          _storeAddress = _currentAddress;

          setState(() {
            markers.add(
              Marker(
                markerId: MarkerId('${_currentPosition}'),
                position: LatLng(
                    _currentPosition.latitude, _currentPosition.longitude),
                infoWindow: InfoWindow(
                  title: _storeAddress,
                  onTap: () async {
                    setState(() {
                      SellerPersonalData.address = storeAddressController.text;
                      SellerPersonalData.latitude = _storePosition.latitude;
                      SellerPersonalData.longitude = _storePosition.longitude;
                    });
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                          builder: (_) => SellerSignUpPage()),
                    );
                  },
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          });
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void _getCoordinates(String address) async {
    try {
      await Geocoder.local.findAddressesFromQuery(address).then((p) {
        var place = p.first;

        setState(() {
          SellerPersonalData.locality = place.locality;
          SellerPersonalData.subLocality = place.subLocality;
          SellerPersonalData.state = place.adminArea;

          _storePosition =
              LatLng(place.coordinates.latitude, place.coordinates.longitude);

          markers.clear();
          setState(() {
            markers.add(
              Marker(
                markerId: MarkerId('${_storePosition}'),
                position: _storePosition,
                infoWindow: InfoWindow(
                  title: storeAddressController.text,
                  onTap: () async {
                    setState(() {
                      SellerPersonalData.address = storeAddressController.text;
                      SellerPersonalData.latitude = _storePosition.latitude;
                      SellerPersonalData.longitude = _storePosition.longitude;
                    });
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                          builder: (_) => SellerSignUpPage()),
                    );
                  },
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          });

          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _storePosition,
                zoom: 18.0,
              ),
            ),
          );
        });
      });
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
    return Container(
      child: Stack(
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
                        label: 'Store Address',
                        hint: 'Store Address',
                        initialValue: "_currentAddress",
                        prefixIcon: Icon(Icons.location_on),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.my_location),
                          onPressed: () {
                            storeAddressController.text = _currentAddress;
                            _storeAddress = _currentAddress;

                            markers.clear();
                            setState(() {
                              markers.add(
                                Marker(
                                  markerId: MarkerId('${_currentPosition}'),
                                  position: LatLng(_currentPosition.latitude,
                                      _currentPosition.longitude),
                                  infoWindow: InfoWindow(
                                    title: _currentAddress,
                                    onTap: () async {
                                      setState(() {
                                        SellerPersonalData.address =
                                            storeAddressController.text;
                                        SellerPersonalData.latitude =
                                            _storePosition.latitude;
                                        SellerPersonalData.longitude =
                                            _storePosition.longitude;
                                      });
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute<void>(
                                            builder: (_) => SellerSignUpPage()),
                                      );
                                    },
                                  ),
                                  icon: BitmapDescriptor.defaultMarker,
                                ),
                              );
                            });

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
                        controller: storeAddressController,
                        width: SizeConfig.screenWidth,
                        locationCallback: (String value) {
                          setState(() {
                            _storeAddress = value;
                          });
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
                      await _getCoordinates(storeAddressController.text);
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
}
