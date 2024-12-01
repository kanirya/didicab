import 'dart:async';
import 'dart:math';
import 'package:didiauth2/Auth/Provider/Driver_auth_provider.dart';
import 'package:didiauth2/Driver/directions.dart';
import 'package:didiauth2/Driver/directions_model.dart';
import 'package:didiauth2/Global_variables.dart';
import 'package:didiauth2/helpers/UiHelpers.dart';
import 'package:didiauth2/helpers/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleMapDriver extends StatefulWidget {
  final List<dynamic> name;
  final List<dynamic> phoneNumber;
  final LatLng drop;
  final String dropLocation;
  final List<LatLng> dropLatLng;
  final String uid;

  const GoogleMapDriver({
    Key? key,
    required this.name,
    required this.phoneNumber,
    required this.dropLocation,
    required this.drop,
    required this.dropLatLng,
    required this.uid,
  }) : super(key: key);

  @override
  _GoogleMapDriverState createState() => _GoogleMapDriverState();
}

class _GoogleMapDriverState extends State<GoogleMapDriver> {
  late Completer<GoogleMapController> _googleMapCompleterController;
  GoogleMapController? _controllerGoogleMap;
  Position? _currentPositionOfUser;
  List<Marker> _markers = [];
  Set<Polyline> _polylines = {};
  Marker nearest = Marker(markerId: MarkerId('5'), position: LatLng(0, 0));
  Directions? _info;
  BitmapDescriptor? _liveLocationIcon;
  final DirectionRepo _directionRepo = DirectionRepo(dio: Dio());
  static const LatLng sourceLocation = LatLng(33.643237, 73.075215);
  static const LatLng desLocation = LatLng(33.639942, 73.071558);

  Future<void> _setCustomLiveLocationMarker() async {
    _liveLocationIcon = await getBytesFromAsset1('assets/images/hd.png', 120);
  }

  @override
  void initState() {
    super.initState();
    _googleMapCompleterController = Completer();
    _initializeMarkers();
    _getCurrentLiveLocationOfUser();
    _saveState();
    getPolyPoints();
    _getDirections(LatLng(33.895294, 70.106560));
    _saveMarkersToFirebase();
    _setCustomLiveLocationMarker();
  }

  Future<void> _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('page2', 'googleMapDriver');
    await prefs.setStringList('names2', widget.name.cast<String>());
    await prefs.setStringList(
        'phoneNumbers2', widget.phoneNumber.cast<String>());
    await prefs.setString('dropLocation2', widget.dropLocation);
    await prefs.setString(
        'dropLatLng2',
        widget.dropLatLng
            .map((latLng) => '${latLng.latitude},${latLng.longitude}')
            .join(';'));
    await prefs.setString('uid2', widget.uid);
    await prefs.setDouble('dropLat2', widget.drop.latitude);
    await prefs.setDouble('dropLng2', widget.drop.longitude);
  }

  List<LatLng> polyCor = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleMapKey,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(desLocation.latitude, desLocation.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polyCor.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {

      });
    }
  }

  Future<void> _saveMarkersToFirebase() async {
    final ref = FirebaseDatabase.instance.ref('Marker/${widget.uid}');

    List<Map<String, dynamic>> markersToSave = _markers.map((marker) {
      return {
        'markerId': marker.markerId.value,
        'position': {
          'latitude': marker.position.latitude,
          'longitude': marker.position.longitude,
        },
        'infoWindow': {
          'title': marker.infoWindow.title,
          'snippet': marker.infoWindow.snippet,
        },
      };
    }).toList();

    await ref.set(markersToSave);
  }

  void _initializeMarkers() async {
    for (int i = 0; i < widget.dropLatLng.length; i++) {
      Marker marker = Marker(
        markerId: MarkerId('marker$i'),
        position: widget.dropLatLng[i],
        icon: await getBytesFromAsset('assets/images/man.png', 120),
        infoWindow: InfoWindow(
          title: widget.name[i],
          snippet: widget.phoneNumber[i],
          onTap: () => _showMarkerDialog(i),
        ),
      );
      _markers.add(marker);
    }

    Marker destinationMarker = Marker(
      markerId: MarkerId("destination"),
      position: widget.drop,
      icon: await getBytesFromAsset('assets/images/1.png', 120),
      infoWindow: InfoWindow(
        title: widget.dropLocation,
        snippet: "Drop Location",
      ),
    );

    _markers.add(destinationMarker);
  }

  void _showMarkerDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "${widget.name[index]}\n${widget.phoneNumber[index]}",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _removeMarker(index);
                    _removeMarkerFromDB(index);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Picked",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.call,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void _removeMarker(int index) {
    setState(() {
      widget.name.removeAt(index);
      widget.phoneNumber.removeAt(index);
      _markers.removeAt(index);
    });
    _findAndNavigateToNearestMarker();
  }

  void _removeMarkerFromDB(int index) {
    setState(() {
      widget.name.removeAt(index);
      widget.phoneNumber.removeAt(index);
      _markers.removeAt(index);
    });

    _updateMarkersInFirebase();
    _findAndNavigateToNearestMarker();
  }

  void Endride(BuildContext context, DatabaseReference ref) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('page2');
    await prefs.remove('names2');
    await prefs.remove('phoneNumbers2');
    await prefs.remove('dropLocation2');
    await prefs.remove('dropLatLng2');
    await prefs.remove('uid2');
    await prefs.remove('dropLat2');
    await prefs.remove('dropLng2');

    DatabaseReference rideRef = FirebaseDatabase.instance
        .reference()
        .child('rides')
        .child(ap.driverModel.uid);
    rideRef.remove();

    ref.child(ap.driverModel.uid).remove();
  }

  void _updateMarkersInFirebase() {
    final ref = FirebaseDatabase.instance.ref('Marker/${widget.uid}');
    List<Map<String, dynamic>> markersData = _markers.map((marker) {
      return {
        'markerId': marker.markerId.value,
        'position': {
          'latitude': marker.position.latitude,
          'longitude': marker.position.longitude,
        },
        'infoWindow': {
          'title': marker.infoWindow.title,
        },
      };
    }).toList();

    ref.set(markersData);
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
      _updateLiveLocationMarker();
    });
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPositionOfUser = position;
        _updateLiveLocationMarker();
      });
      _findAndNavigateToNearestMarker();
    });
  }
  void _updateLiveLocationMarker() {
    if (_currentPositionOfUser == null || _liveLocationIcon == null) return;

    Marker liveLocationMarker = Marker(
      markerId: MarkerId('live_location'),
      position: LatLng(
          _currentPositionOfUser!.latitude, _currentPositionOfUser!.longitude),
      icon: _liveLocationIcon!,
      infoWindow: InfoWindow(title: 'Your Location'),
    );

    setState(() {
      _markers
          .removeWhere((marker) => marker.markerId.value == 'live_location');
      _markers.add(liveLocationMarker);
    });
  }

  void _findAndNavigateToNearestMarker() {
    if (_currentPositionOfUser == null || _markers.isEmpty) return;

    Marker nearestMarker = _findNearestMarker();

    LatLng positionOfUserInLatLng = LatLng(
      _currentPositionOfUser!.latitude,
      _currentPositionOfUser!.longitude,
    );
    CameraPosition cameraPosition = CameraPosition(
      target: positionOfUserInLatLng,
      zoom: 16,
    );
    _controllerGoogleMap?.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  Marker _findNearestMarker() {
    double minDistance = double.infinity;
    Marker nearestMarker = _markers[0];

    for (Marker marker in _markers) {
      double distance = _calculateDistance(
        _currentPositionOfUser!.latitude,
        _currentPositionOfUser!.longitude,
        marker.position.latitude,
        marker.position.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestMarker = marker;
        nearest = nearestMarker;
      }
      _getDirections(nearestMarker.position);
    }
    return nearestMarker;
  }

  double _calculateDistance(
      double lat1, double long1, double lat2, double long2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    double latDiff = _radians(lat2 - lat1);
    double longDiff = _radians(long2 - long1);
    double a = sin(latDiff / 2) * sin(latDiff / 2) +
        cos(_radians(lat1)) *
            cos(_radians(lat2)) *
            sin(longDiff / 2) *
            sin(longDiff / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  double _radians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> _getDirections(LatLng destination) async {
    if (_currentPositionOfUser == null) return;

    final directions = await _directionRepo.getDirections(
      origin: LatLng(
        _currentPositionOfUser!.latitude,
        _currentPositionOfUser!.longitude,
      ),
      destination: destination,
    );

    setState(() {
      _info = directions;
      _polylines = {
        Polyline(
          polylineId: PolylineId('overview_polyline'),
          color: Colors.red,
          width: 5,
          points: directions!.polylinePoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final ref = FirebaseDatabase.instance.ref('DriversHavingPassengerData');
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(33.662898, 73.084721),
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController mapController) {
              _controllerGoogleMap = mapController;
              _googleMapCompleterController.complete(_controllerGoogleMap);
              _getCurrentLiveLocationOfUser();
            },
            markers: Set<Marker>.of(_markers),
            polylines: {
              Polyline(polylineId: PolylineId("route"),
              points: polyCor,
              color: Colors.blue,
                width: 6
              ),

            },
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                height: 50,
                width: 100,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      )
                    ]),
                child: Text(
                  '${_info?.totalDistance}, ${_info?.totalDuration}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          Positioned(
            bottom: 140,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    if (_controllerGoogleMap != null) {
                      final GoogleMapController controller =
                          await _googleMapCompleterController.future;
                      controller.animateCamera(CameraUpdate.zoomIn());
                    }
                  },
                  backgroundColor: Color(0xffffffff),
                  mini: true,
                  child: Icon(Icons.zoom_in),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    if (_controllerGoogleMap != null) {
                      final GoogleMapController controller =
                          await _googleMapCompleterController.future;
                      controller.animateCamera(CameraUpdate.zoomOut());
                    }
                  },
                  mini: true,
                  child: Icon(Icons.zoom_out),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () async {
                    _controllerGoogleMap?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            _currentPositionOfUser!.latitude,
                            _currentPositionOfUser!.longitude,
                          ),
                          zoom: 18,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Color(0xffffffff),
                  mini: true,
                  child: Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
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
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        title: Text("End Ride"),
                                        content: Text(
                                            "Do you want to End Your ride?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("No")),
                                          TextButton(
                                            onPressed: () {
                                              Endride(context, ref);
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      splash(),
                                                ),
                                                (route) => false,
                                              );
                                            },
                                            child: Text("Yes"),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: Container(
                                height: 50,
                                color: Colors.grey[200],
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                    child: Text(
                                  "End Ride",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 80,
                color: mainColor,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      LineAwesomeIcons.arrow_up,
                      size: 35,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Tap to show menu",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverLocationService {
  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref('driverLocations');

  Future<void> shareLocation(String uid) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.requestPermission();
    }

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _ref.child(uid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    });
  }
}
