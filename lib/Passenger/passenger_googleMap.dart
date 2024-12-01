import 'dart:async';
import 'package:didiauth2/helpers/UiHelpers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Global_variables.dart';
import '../helpers/splash_screen.dart';

class passengerGoogleMap extends StatefulWidget {
  final LatLng drop;
  final String uid;
  final List<LatLng> dropLatLng;

  const passengerGoogleMap({
    Key? key,
    required this.drop,
    required this.dropLatLng,
    required this.uid,
  }) : super(key: key);

  @override
  State<passengerGoogleMap> createState() => _passengerGoogleMapState();
}

class _passengerGoogleMapState extends State<passengerGoogleMap> {
  late Completer<GoogleMapController> _googleMapCompleterController;
  GoogleMapController? _controllerGoogleMap;
  List<Marker> _markers = [];
  late DatabaseReference _driverLocationRef;
  late DatabaseReference _markersRef;
  Marker? _driverMarker;
  Position? _currentPositionOfUser;
  Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  @override
  void initState() {
    super.initState();
    _googleMapCompleterController = Completer();
    _initializeMarkers();
    _listenToDriverLocation();
    _listenToMarkersChanges();
    _getCurrentLiveLocationOfUser();
    _getCurrentLocationAndDrawPolyline();
    _saveState();
  }


  Future<void> _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('page3', 'googleMapPassenger');

    await prefs.setString(
        'dropLatLng2',
        widget.dropLatLng
            .map((latLng) => '${latLng.latitude},${latLng.longitude}')
            .join(';'));
    await prefs.setString('uid2', widget.uid);
    await prefs.setDouble('dropLat2', widget.drop.latitude);
    await prefs.setDouble('dropLng2', widget.drop.longitude);
  }
void EndRide()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('page3');

  await prefs.remove('dropLatLng2');
  await prefs.remove('uid2');
  await prefs.remove('dropLat2');
  await prefs.remove('dropLng2');
}



  void _initializeMarkers()async {
    for (int i = 0; i < widget.dropLatLng.length; i++) {
      Marker marker = Marker(
        markerId: MarkerId('marker$i'),
        position: widget.dropLatLng[i],
        icon: await getBytesFromAsset('assets/images/man.png', 120),
      );
      _markers.add(marker);
    }

    Marker destinationMarker = Marker(
      markerId: MarkerId("destination"),
      position: widget.drop,
      icon:await getBytesFromAsset('assets/images/1.png', 120),
      infoWindow: InfoWindow(
        title: 'Drop Location',

      ),
    );
    _markers.add(destinationMarker);
  }

  void _listenToDriverLocation() {
    _driverLocationRef = FirebaseDatabase.instance.ref('driverLocations/${widget.uid}');
    _driverLocationRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final double latitude = data['latitude'];
        final double longitude = data['longitude'];

        LatLng driverPosition = LatLng(latitude, longitude);

        setState(() {
          _driverMarker = Marker(
            markerId: MarkerId('driver'),
            position: driverPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: 'Driver'),
          );

          _markers.removeWhere((marker) => marker.markerId == MarkerId('driver'));
          _markers.add(_driverMarker!);
        });

        _updateCameraPosition(driverPosition);
      }
    });
  }

  void _listenToMarkersChanges() {
    _markersRef = FirebaseDatabase.instance.ref('Marker/${widget.uid}');
    _markersRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        List<dynamic> markersData = event.snapshot.value as List<dynamic>;

        setState(() {
          _markers = markersData.map((markerData) {
            final position = markerData['position'];
            return Marker(
              markerId: MarkerId(markerData['markerId']),
              position: LatLng(position['latitude'], position['longitude']),
              infoWindow: InfoWindow(
                title: markerData['infoWindow']['title'],
              ),
            );
          }).toList();

          // Ensure the driver marker is included
          if (_driverMarker != null) {
            _markers.add(_driverMarker!);
          }
        });
      }
    });
  }



  void _updateCameraPosition(LatLng position) {
    _controllerGoogleMap?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }
  Future<void> _getCurrentLiveLocationOfUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    setState(() {
      _currentPositionOfUser = position;
    });

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPositionOfUser = position;
      });
    });
  }

  Future<void> _getCurrentLocationAndDrawPolyline() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng currentPosition = LatLng(position.latitude, position.longitude);
    _getPolylineCoordinates(currentPosition, widget.drop);
  }

  void _getPolylineCoordinates(LatLng start, LatLng end) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapKey, // Replace with your Google Maps API key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _addPolyline();
  }

  void _addPolyline() {
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('polyline'),
        points: _polylineCoordinates,
        color: Colors.blue,
        width: 5,
      ));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(33.662898, 73.084721),
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController mapController) {
              _controllerGoogleMap = mapController;
              _googleMapCompleterController.complete(_controllerGoogleMap);
            },
            markers: Set<Marker>.of(_markers),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                          height: 400,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    EndRide();
                                    if (mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => splash(),
                                        ),
                                            (route) => false,
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    color: Colors.grey[200],
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                        child: Text(
                                          "Ride End",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ));
                    });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: Colors.grey[400],
                child: Icon(
                  LineAwesomeIcons.arrow_up,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
