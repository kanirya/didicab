import 'dart:async';
import 'package:didiauth2/helpers/custom.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PassengerMap extends StatefulWidget {
  const PassengerMap({Key? key}) : super(key: key);

  @override
  State<PassengerMap> createState() => _PassengerMapState();
}

class _PassengerMapState extends State<PassengerMap> {
  List<Marker> myMarker = [];
  LatLng? selectedLocation;
  Position? _currentPositionOfUser;
  late Completer<GoogleMapController> _googleMapCompleterController;
  GoogleMapController? _controllerGoogleMap;

  @override
  void initState() {
    super.initState();
    _googleMapCompleterController = Completer();
    _getCurrentLiveLocationOfUser();
  }

  Future<void> _getCurrentLiveLocationOfUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.requestPermission();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    setState(() {
      _currentPositionOfUser = position;
    });

    _animateCameraToPosition(position);

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPositionOfUser = position;
      });
      _animateCameraToPosition(position);
    });
  }

  void _animateCameraToPosition(Position position) {
    if (_controllerGoogleMap != null) {
      _controllerGoogleMap!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,

            initialCameraPosition: const CameraPosition(
              target: LatLng(33.662898, 73.084721),
              zoom: 17,
            ),
            onMapCreated: (GoogleMapController mapController) {
              _controllerGoogleMap = mapController;
              _googleMapCompleterController.complete(_controllerGoogleMap);
            },
            markers:Set.of(myMarker),
            onTap: _handleClick,
            myLocationEnabled: true,
            myLocationButtonEnabled:
                false,
          ),
          Positioned(
            bottom: 80,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                 BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "Tap on a location from where do you want to go",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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
                    if (_controllerGoogleMap != null &&
                        _currentPositionOfUser != null) {
                      final GoogleMapController controller =
                          await _googleMapCompleterController.future;
                      controller.animateCamera(CameraUpdate.newLatLng(
                        LatLng(_currentPositionOfUser!.latitude,
                            _currentPositionOfUser!.longitude),
                      ));
                    }
                  },
                  backgroundColor: Color(0xffffffff),
                  mini: true,
                  child: Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
                child: CustomButton(
                    text: 'Location Selected',
                    onPressed: () {
                      if (selectedLocation != null) {
                        Navigator.pop(context, selectedLocation);
                      }
                    })),
          ),
        ],
      ),
    );
  }

  void _handleClick(LatLng tappedPoint) {
    setState(() {
      myMarker = [
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
        ),
      ];
      selectedLocation = tappedPoint;
    });
  }

}
