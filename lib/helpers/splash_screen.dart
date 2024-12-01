import 'dart:async';

import 'package:didiauth2/Auth/Provider/Driver_auth_provider.dart';
import 'package:didiauth2/Driver/DriverHomeScreen.dart';
import 'package:didiauth2/Global_variables.dart';
import 'package:didiauth2/Passenger/Passenger_Another.dart';
import 'package:didiauth2/Passenger/Passenger_homeScreen.dart';
import 'package:didiauth2/Passenger/passenger_googleMap.dart';
import 'package:didiauth2/notification_services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/Provider/Passenger_auth_provider.dart';
import '../Auth/WelcomeScreen.dart';

import '../Driver/Driver_passengerData.dart';
import '../Driver/Google_map_driver.dart';

class splash extends StatefulWidget {
  const splash({super.key});

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AuthProviderPassenger>(context, listen: false);
    notificationServices.requestNotification();
    notificationServices.firebaseInit();
    notificationServices.getDeviceToken().then((value) {
      print(" Device token ${value}");
    });

    Timer(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? page = prefs.getString('pagepp');
      String? uid = prefs.getString('uidpp');
      String? pick2 = prefs.getString('pick2pp');
      String? drop2 = prefs.getString('drop2pp');
      String? date2 = prefs.getString('date2pp');
      String? seats = prefs.getString('seatspp');
      String? fare = prefs.getString('farepp');
      String? color = prefs.getString('colorpp');
      String? make = prefs.getString('makepp');
      String? plateNumber = prefs.getString('plateNumberpp');
      String? profileURL = prefs.getString('profileURLpp');
      String? name = prefs.getString('namepp');
      String? phoneNumber = prefs.getString('phoneNumberpp');
      String? time = prefs.getString('timepp');
      String? token = prefs.getString('drivertoken');

      //google map sp
      List<String>? names2 = prefs.getStringList('names2');
      List<String>? phoneNumbers2 = prefs.getStringList('phoneNumbers2');
      String? dropLocation2 = prefs.getString('dropLocation2');
      String? dropLatLngString2 = prefs.getString('dropLatLng2');
      String? uid2 = prefs.getString('uid2');
      double? dropLat2 = prefs.getDouble('dropLat2');
      double? dropLng2 = prefs.getDouble('dropLng2');

      // Parse LatLng list
      List<LatLng> dropLatLng = [];
      if (dropLatLngString2 != null) {
        List<String> latLngStrings = dropLatLngString2.split(';');
        for (var latLng in latLngStrings) {
          try {
            List<String> coords = latLng.split(',');
            if (coords.length == 2) {
              double lat = double.parse(coords[0]);
              double lng = double.parse(coords[1]);
              dropLatLng.add(LatLng(lat, lng));
            }
          } catch (e) {
            print('Error parsing LatLng: $e');
          }
        }
      }

      if (prefs.getString('page3') == 'googleMapPassenger' &&
          prefs.getString('uid2') != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => passengerGoogleMap(
                      dropLatLng: dropLatLng,
                      drop: LatLng(dropLat2!, dropLng2!),
                      uid: uid2!,
                    )));
      } else if (prefs.getString('page2') == 'googleMapDriver' &&
          prefs.getString('uid2') != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => GoogleMapDriver(
                      name: names2!,
                      phoneNumber: phoneNumbers2!,
                      dropLocation: dropLocation2!,
                      drop: LatLng(dropLat2!, dropLng2!),
                      dropLatLng: dropLatLng,
                      uid: uid2!,
                    )));
      } else if (page == 'rideDetails' && uid != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AnotherPassengerData(
                    uid: uid,
                    pick2: pick2!,
                    drop2: drop2!,
                    date2: date2!,
                    seats: seats!,
                    fare: fare!,
                    color: color!,
                    make: make!,
                    plateNumber: plateNumber!,
                    profileURL: profileURL!,
                    name: name!,
                    phoneNumber: phoneNumber!,
                    time: time!,
                    token: token!,
                  )),
        );
      } else if (prefs.getString('page1') == 'driverPassengerData' &&
          prefs.getString('uidd') != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => driverPassengerData(
              uid: prefs.getString('uidd')!,
              pick2: prefs.getString('pick2d')!,
              drop2: prefs.getString('drop2d')!,
              date2: prefs.getString('date2d')!,
              seats: prefs.getString('seatsd')!,
              fare: prefs.getString('fared')!,
              color: prefs.getString('colord')!,
              make: prefs.getString('maked')!,
              plateNumber: prefs.getString('plateNumberd')!,
              ref: FirebaseDatabase.instance
                  .ref("FromTo")
                  .child(prefs.getString('refd')!),
              // Adjust this if you need a specific reference
              time: prefs.getString('timed')!,
              path: prefs.getString('refd')!,
            ),
          ),
        );
      } else if (ap.isSignedIn == true) {
        await ap.getDataFromSP().whenComplete(
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const NavigationMenu(),
              ),
            );
          },
        );
      } else if (app.isPassengerSignIn == true) {
        await app.getDataFromSPP().whenComplete(
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const NavigationMenuPassenger(),
                ),
              ),
            );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 300,
              ),
              Container(
                height: 60,
                width: 100,
                child: SvgPicture.asset(
                  'assets/images/didi svg logo.svg',
                  color: Color(0xffffffff),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                height: 100,
                width: 180,
                child: SvgPicture.asset(
                  'assets/images/letsGo SVG Logo.svg',
                  color: Color(0xff000000),
                ),
              ),
              const SizedBox(
                height: 90,
              ),
              CircularProgressIndicator(
                backgroundColor: Colors.white,
                color: mainColor,
              )
            ],
          ),
        ],
      ),
    );
  }
}
