import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Google_Maps extends StatefulWidget {
  @override
  _Google_MapsState createState() => _Google_MapsState();
}

class _Google_MapsState extends State<Google_Maps> {
  Completer<GoogleMapController> _controller = Completer();

  var currentLocation;

  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  static LatLng _center = LatLng(0.0, 0.0);

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      forceAndroidLocationManager: false,
    );
    print(position);
    setState(() {
      // _center = LatLng(position.latitude,position.longitude);
      currentLocation = position;
    });
  }

  MapType _currentMapType = MapType.normal;

  final Set<Marker> _markers = {
  Marker(
  // This marker id can be anything that uniquely identifies each marker.
  markerId: MarkerId("Gautam"),
  position: LatLng(21.2275933,72.8222495),
  infoWindow: InfoWindow(
  title: "Gautam's Home",
  snippet: '5 Star Rating',
  ),
  icon: BitmapDescriptor.defaultMarker,
  ),

    Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId("Shruti"),
      position: LatLng(21.2223185,72.8851605),
      infoWindow: InfoWindow(
        title: "Shruti's Home",
        snippet: '0 Star Rating',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ),

    Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId("Utsav"),
      position: LatLng(21.2092146,72.8699682),
      infoWindow: InfoWindow(
        title: "Utsav's Home",
        snippet: '2 Star Rating',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ),

    Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId("Darshita"),
      position: LatLng(21.2090886,72.8708608),
      infoWindow: InfoWindow(
        title: "Darshita's Home",
        snippet: '4 Star Rating',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ),

    Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId("Shahil"),
      position: LatLng(21.2346936,72.8569163),
      infoWindow: InfoWindow(
        title: "Shahil's Home",
        snippet: '5 Star Rating',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ),
  };

  LatLng _lastMapPosition = _center;

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'Really cool place',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps Sample App'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              markers: _markers,
              onCameraMove: _onCameraMove,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 13.5,
              ),
              mapType: _currentMapType,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: _onMapTypeButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.map, size: 36.0),
                    ),
                    SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: _onAddMarkerButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.add_location, size: 36.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
