import 'package:didiauth2/Auth/Provider/Passenger_auth_provider.dart';
import 'package:didiauth2/Passenger/passenger_googleMap.dart';
import 'package:didiauth2/api/sendNotification.dart';
import 'package:didiauth2/helpers/custom.dart';
import 'package:didiauth2/helpers/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AnotherPassengerData extends StatefulWidget {
  final String uid;
  final String pick2;
  final String drop2;
  final String date2;
  final String seats;
  final String fare;
  final String color;
  final String make;
  final String plateNumber;
  final String profileURL;
  final String name;
  final String phoneNumber;
  final String time;
  final String token;

  const AnotherPassengerData({
    super.key,
    required this.uid,
    required this.pick2,
    required this.drop2,
    required this.date2,
    required this.seats,
    required this.fare,
    required this.color,
    required this.make,
    required this.plateNumber,
    required this.profileURL,
    required this.name,
    required this.phoneNumber,
    required this.time, required this.token,
  });

  @override
  State<AnotherPassengerData> createState() => _AnotherPassengerDataState();
}

class _AnotherPassengerDataState extends State<AnotherPassengerData> {
  late String _uid;
  List<LatLng> coordinateList = [];
  late LatLng droplocation;
  late DatabaseReference rideRef;

  @override
  void initState() {
    super.initState();
    _uid = widget.uid;
    _saveRideData();
    rideRef = FirebaseDatabase.instance.ref().child('rides').child(widget.uid);
  }

  Future<void> _saveRideData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('pagepp', 'rideDetails');
    await prefs.setString('uidpp', widget.uid);
    await prefs.setString('pick2pp', widget.pick2);
    await prefs.setString('drop2pp', widget.drop2);
    await prefs.setString('date2pp', widget.date2);
    await prefs.setString('seatspp', widget.seats);
    await prefs.setString('farepp', widget.fare);
    await prefs.setString('colorpp', widget.color);
    await prefs.setString('makepp', widget.make);
    await prefs.setString('plateNumberpp', widget.plateNumber);
    await prefs.setString('profileURLpp', widget.profileURL);
    await prefs.setString('namepp', widget.name);
    await prefs.setString('phoneNumberpp', widget.phoneNumber);
    await prefs.setString('timepp', widget.time);
    await prefs.setString('drivertoken', widget.token);
  }

  Future<void> _navigateToDriverNextPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('pagepp');
    await prefs.remove('uidpp');
    await prefs.remove('pick2pp');
    await prefs.remove('drop2pp');
    await prefs.remove('date2pp');
    await prefs.remove('seatspp');
    await prefs.remove('farepp');
    await prefs.remove('colorpp');
    await prefs.remove('makepp');
    await prefs.remove('plateNumberpp');
    await prefs.remove('profileURLpp');
    await prefs.remove('namepp');
    await prefs.remove('phoneNumberpp');
    await prefs.remove('timepp');
    await prefs.remove('drivertoken');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => passengerGoogleMap(
                    drop: droplocation,
                    dropLatLng: coordinateList,
                    uid: widget.uid,
                  )),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.drop2 == 'Parachinar') {
      droplocation = LatLng(33.897037, 70.104586);
    } else if (widget.drop2 == 'Islamabad') {
      droplocation = LatLng(33.662898, 73.084721);
    } else if (widget.drop2 == 'Peshawar') {
      droplocation = LatLng(34.008265, 71.569007);
    }

    final passengerRef =
        FirebaseDatabase.instance.ref("DriversHavingPassengerData").child(_uid);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ride Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: ListView(
          children: [
            Container(
              height: 110,
              width: 200,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black38)),
              child: Row(
                children: [
                  const SizedBox(
                    width: 40,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 4,
                        child: const Center(
                          child: Text(
                            "|||",
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 20,
                        width: 80,
                        child: Text(
                          widget.pick2,
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        height: 12,
                        width: 80,
                        child: Text(
                          widget.date2,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                              fontSize: 10),
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Container(
                        height: 20,
                        width: 80,
                        child: Text(
                          widget.drop2,
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: 4,
                        height: 80,
                        child: const Text(
                          "||||||||",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 120,
                    width: 110,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 72,
                          left: 10,
                          child: Container(
                            width: 40,
                            child: const Text(
                              "Booked Seats",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          left: 50,
                          child: Container(
                            height: 20,
                            width: 20,
                            color: Colors.grey[400],
                            child: Center(
                              child: Text(
                                widget.seats,
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 18,
                          child: Container(
                            width: 40,
                            height: 37,
                            child: SvgPicture.asset(
                                'assets/images/Car Details.svg'),
                          ),
                        ),
                        Positioned(
                          top: 13,
                          left: 55,
                          child: Container(
                            width: 33,
                            height: 28,
                            child: Text(
                              "${widget.color}\n${widget.make}",
                              style: TextStyle(
                                  fontSize: 8, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 36,
                          left: 55,
                          child: Container(
                            width: 40,
                            height: 18,
                            child: Text(
                              "[ ${widget.plateNumber} }",
                              style: TextStyle(
                                  fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 46,
                          left: 0,
                          child: Container(
                            width: 100,
                            height: 19,
                            child: Center(
                              child: Text(
                                "--------------------",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 380,
                  width: MediaQuery.of(context).size.width * .8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        // const SizedBox(height: 4,),
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 30,
                              width: 150,
                              child: const Center(
                                child: Text(
                                  "Passenger Details",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 20,
                              child: const Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: FirebaseAnimatedList(
                            query: passengerRef,
                            itemBuilder:
                                ((context, snapshot, animation, index) {
                              double latitude = double.parse(snapshot
                                  .child('location')
                                  .child('lat')
                                  .value
                                  .toString());
                              double longitude = double.parse(snapshot
                                  .child('location')
                                  .child('long')
                                  .value
                                  .toString());
                              LatLng latLng2 = LatLng(latitude, longitude);
                              coordinateList.add(latLng2);
                              return Container(
                                child: ListTile(
                                  title: Text(
                                    snapshot
                                        .child('passengerName')
                                        .value
                                        .toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  leading: const Icon(
                                    Icons.circle_outlined,
                                    size: 15,
                                    color: Colors.green,
                                  ),
                                  subtitle: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 15,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: .5),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: const Center(
                                              child: Text(
                                                "Person",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            width: 20,
                                            height: 20,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Text(
                                                snapshot
                                                    .child("passengerBookSeats")
                                                    .value
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            height: 15,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: .5),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Center(
                                              child: Text(
                                                snapshot
                                                    .child("gender")
                                                    .value
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Bio: ',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Container(
                                                height: 57,
                                                width: 170,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: Center(
                                                    child: Text(
                                                      snapshot
                                                          .child('bio')
                                                          .value
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 11),
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 40,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey[300],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 85,
                          width: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey[200],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              backgroundImage: NetworkImage(widget.profileURL),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 17,
                          width: 120,
                          child: Center(
                            child: Text(
                              widget.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                        Container(
                          height: 17,
                          width: 100,
                          child: Center(
                              child: Text(
                            widget.phoneNumber,
                            style: TextStyle(fontSize: 11),
                          )),
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: [
                        Center(
                          child: Container(
                            height: 30,
                            width: 160,
                            child: Text(
                              'Time: ${widget.time}',
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 150,
                              height: 20,
                              child: Text(
                                "fear :${widget.fare}",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            StreamBuilder<DatabaseEvent>(
              stream: rideRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(child: Text('Ride not found'));
                }

                var rideData =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                var rideStatus = rideData['rideStatus'];

                return Center(
                  child: CustomButton(
                    text: rideStatus == 'started'
                        ? 'Go to Google Maps'
                        : 'Cancel Ride',
                    onPressed: () {
                      if (rideStatus == 'started') {
                        _navigateToDriverNextPage();
                      } else {
                        cancelRide(widget.token);
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void cancelRide(String token) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('pagepp');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Cancel Ride"),
            content: Text("Do you want to cancel your ride?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              TextButton(
                  onPressed: () {

                    final app = Provider.of<AuthProviderPassenger>(context,
                        listen: false);
                    sendPushMessage(token, "Cancel ride", "${app.passengerModel.passengerName} Cancel his ride with you");
                    final passengerRef = FirebaseDatabase.instance
                        .ref("DriversHavingPassengerData")
                        .child(widget.uid)
                        .child(app.passengerModel.uidp);
                    passengerRef.remove().then((onValue) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => splash()),
                        (Route<dynamic> route) => false,
                      );
                    });
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }
}
