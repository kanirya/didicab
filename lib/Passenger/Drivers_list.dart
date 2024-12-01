import 'dart:async';

import 'package:didiauth2/Auth/Provider/Passenger_auth_provider.dart';
import 'package:didiauth2/Global_variables.dart';
import 'package:didiauth2/api/access_token.dart';
import 'package:didiauth2/api/sendNotification.dart';
import 'package:didiauth2/helpers/UiHelpers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'Passenger_Another.dart';
class driverList extends StatefulWidget {
  final pick;
  final drop;
  final person;
  final LatLng selectedlocation;
  final DateTime time;

  const driverList(
      {super.key,
      this.pick,
      this.drop,
      required this.person,
      required this.selectedlocation,
      required this.time});

  @override
  State<driverList> createState() => _driverListState();
}

class _driverListState extends State<driverList> {
  // final auth = FirebaseAuth.instance;
  var refrence;
  final ref1 =
      FirebaseDatabase.instance.ref("FromTo").child('ParachinarToIslamabad');
  final ref2 =
      FirebaseDatabase.instance.ref("FromTo").child('ParachinarToPeshawar');
  final ref3 =
      FirebaseDatabase.instance.ref("FromTo").child('IslamabadToParachinar');
  final ref4 =
      FirebaseDatabase.instance.ref("FromTo").child('PeshawarToParachinar');

  @override
  Widget build(BuildContext context) {
    if (widget.pick == "Parachinar" && widget.drop == "Islamabad") {
      refrence = ref1;
    } else if (widget.pick == "Parachinar" && widget.drop == "Peshawar") {
      refrence = ref2;
    } else if (widget.pick == "Islamabad" && widget.drop == "Parachinar") {
      refrence = ref3;
    } else if (widget.pick == "Peshawar" && widget.drop == "Parachinar") {
      refrence = ref4;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Available Drivers",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Container(
            width: MediaQuery.of(context).size.width * .9,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[200],
            ),
            child: Center(
                child: Text(
              "From: ${widget.pick}   To: ${widget.drop}",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            )),
          ),
          Expanded(
            child: buildFirebaseAnimatedList(ref: refrence),
          ),
        ],
      ),
    );
  }

  FirebaseAnimatedList buildFirebaseAnimatedList(
      {required DatabaseReference ref}) {
    return FirebaseAnimatedList(
      query: ref,
      itemBuilder: (context, snapshot, animation, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black26,
            ),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => bookingdata(
                      pick1: snapshot.child('pick').value.toString(),
                      drop1: snapshot.child('drop').value.toString(),
                      name: snapshot.child('name').value.toString(),
                      color: snapshot.child('carColor').value.toString(),
                      fare: snapshot.child('fear').value.toString(),
                      make: snapshot.child('make').value.toString(),
                      plateNumber:
                          snapshot.child('numberPlate').value.toString(),
                      seats: snapshot.child('seats').value.toString(),
                      person: widget.person,
                      profileURL: snapshot.child('profilePic').value.toString(),
                      uid: snapshot.child('uid').value.toString(),
                      selectedlocation: widget.selectedlocation,
                      date: snapshot.child('date').value.toString(),
                      phoneNumber:
                          snapshot.child('DriverPhoneNumber').value.toString(),
                      time: snapshot.child('time').value.toString(),
                      drivertoken:
                          snapshot.child('deviceToken').value.toString(),
                    ),
                  ),
                );
              },
              trailing: Icon(
                Icons.arrow_forward_ios_sharp,
                color: Colors.white,
              ),
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(snapshot.child('profilePic').value.toString()),
              ),
              title: Text(
                snapshot.child('name').value.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 20,
                        child: const Center(
                          child: Text(
                            "Date",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 30,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: mainColor,
                        ),
                        child: Center(
                          child: Text(
                            snapshot.child("date").value.toString(),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: 30,
                        height: 20,
                        child: Center(
                          child: const Text(
                            "Fare",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 40,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: mainColor,
                        ),
                        child: Center(
                          child: Text(
                            snapshot.child("fear").value.toString(),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 20,
                        child: Center(
                          child: const Text(
                            "Seats",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 30,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: mainColor,
                        ),
                        child: Center(
                          child: Text(
                            snapshot.child("seats").value.toString(),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: 30,
                        height: 20,
                        child: Center(
                          child: const Text(
                            "Time",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: mainColor,
                        ),
                        child: Center(
                          child: Text(
                            snapshot.child("time").value.toString(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class bookingdata extends StatefulWidget {
  var pick1;
  var drop1;
  var name;
  var make;
  var color;
  var plateNumber;
  var seats;
  final String fare;
  var person;
  var profileURL;
  final String uid;
  final LatLng selectedlocation;
  final String date;
  final String phoneNumber;
  final String time;
  final String drivertoken;

  bookingdata(
      {super.key,
      required this.pick1,
      required this.drop1,
      required this.name,
      required this.make,
      required this.color,
      required this.plateNumber,
      required this.seats,
      required this.fare,
      required this.person,
      required this.profileURL,
      required this.uid,
      required this.selectedlocation,
      required this.date,
      required this.phoneNumber,
      required this.time,
      required this.drivertoken});

  @override
  State<bookingdata> createState() => _bookingdataState();
}

class _bookingdataState extends State<bookingdata> {
  late int fareInt;
  late int personInt;
  late int sum;
  late String sum1;
  late String _profileURL;
  late int _seats;
  late int _person;
  late int remainingseats;
  bool load = false;
  var refrence;
  final tokenManager = TokenManager();
  final ref1 =
      FirebaseDatabase.instance.ref("FromTo").child('ParachinarToIslamabad');
  final ref2 =
      FirebaseDatabase.instance.ref("FromTo").child('ParachinarToPeshawar');
  final ref3 =
      FirebaseDatabase.instance.ref("FromTo").child('IslamabadToParachinar');
  final ref4 =
      FirebaseDatabase.instance.ref("FromTo").child('PeshawarToParachinar');
  final DriversHavingPassengerData =
      FirebaseDatabase.instance.ref('DriversHavingPassengerData');
  final passengerRef = FirebaseDatabase.instance.ref("PassengerTrips");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fareInt = int.parse(widget.fare);
    personInt = int.parse(widget.person);
    sum = fareInt * personInt;
    _profileURL = widget.profileURL;
    _seats = int.parse(widget.seats);
    _person = int.parse(widget.person);
    remainingseats = _seats - _person;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pick1 == "Parachinar" && widget.drop1 == "Islamabad") {
      refrence = ref1;
    } else if (widget.pick1 == "Parachinar" && widget.drop1 == "Peshawar") {
      refrence = ref2;
    } else if (widget.pick1 == "Islamabad" && widget.drop1 == "Parachinar") {
      refrence = ref3;
    } else if (widget.pick1 == "Peshawar" && widget.drop1 == "Parachinar") {
      refrence = ref4;
    }
    DatabaseReference userReference = refrence.child(widget.uid);
    final app = Provider.of<AuthProviderPassenger>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Ride Details",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black26),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 80,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 55,
                      ),
                      Container(
                        height: 25,
                        width: 35,
                        child: Text(
                          widget.date,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 25,
                        width: 35,
                        child: Text(
                          "${widget.date}",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Container(
                        height: 70,
                        width: 23,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              height: 15,
                              width: 15,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.green),
                            ),
                            Container(
                              height: 30,
                              width: 5,
                              child: const Text(
                                "||",
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                            Container(
                              height: 15,
                              width: 15,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.red),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 35,
                      ),
                      Container(
                        height: 15,
                        width: 100,
                        child: Text("Time:${widget.time}"),
                      ),
                      Container(
                        width: 130,
                        height: 25,
                        child: Text(
                          widget.pick1,
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(height: 18),
                      Container(
                        width: 130,
                        height: 25,
                        child: Text(
                          widget.drop1,
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black26)),
              child: Row(
                children: [
                  const SizedBox(
                    width: 25,
                  ),
                  Column(
                    children: [
                      Container(
                        height: 15,
                        width: 90,
                      ),
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(_profileURL),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 30,
                        width: 110,
                        child: Text(
                          widget.name,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 20,
                    height: 70,
                  ),
                  Container(
                    height: 150,
                    width: 187,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20,
                          child: Container(
                            height: 90,
                            width: 90,
                            child: IconButton(
                              icon: const Center(
                                child: Icon(
                                  LineAwesomeIcons.what_s_app,
                                  color: Colors.green,
                                  size: 70,
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 50,
                          child: Container(
                            height: 40,
                            width: 60,
                            child: SvgPicture.asset(
                                "assets/images/Car Details.svg"),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 0,
                          child: Container(
                            height: 40,
                            width: 60,
                            child: Text(
                              "${widget.color} ${widget.make}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 13),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          right: 10,
                          child: Container(
                            height: 40,
                            width: 80,
                            child: Text(
                              "[${widget.plateNumber}]",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 60,
                          right: 15,
                          child: Container(
                            height: 40,
                            width: 100,
                            child: const Text("_______________"),
                          ),
                        ),
                        Positioned(
                          top: 90,
                          right: 140,
                          child: Container(
                            height: 80,
                            width: 4,
                            child: const Text("||"),
                          ),
                        ),
                        Positioned(
                          top: 90,
                          right: 30,
                          child: Container(
                            height: 40,
                            width: 90,
                            child: const Text(
                              "Available Seats.",
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 90,
                          right: 10,
                          child: Container(
                            height: 40,
                            width: 40,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                widget.seats,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 27),
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
              height: 7,
            ),
            Container(
              width: double.infinity,
              height: 210,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black26),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      Container(height: 113, width: 30),
                      Container(
                        height: 30,
                        width: 30,
                        child: const Icon(Icons.percent_rounded),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 23,
                        width: 155,
                        child: const Text(
                          "Booking Total Price.",
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Container(
                            height: 25,
                            width: 60,
                            decoration: BoxDecoration(
                              border: Border.all(width: .5),
                            ),
                            child: Center(
                                child: Text(
                              widget.person,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            )),
                          ),
                          Container(
                            height: 25,
                            width: 40,
                            child: const Center(
                              child: Text(
                                "X",
                              ),
                            ),
                          ),
                          Container(
                            height: 25,
                            width: 50,
                            child: Center(
                              child: Text(
                                widget.fare,
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black38),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 20,
                        width: 150,
                        child: Text(
                          "-----------------------------------",
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 130,
                        child: Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 150,
                        child: const Text(
                          "-----------------------------------",
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 27,
                    height: 100,
                  ),
                  Container(
                    width: 3,
                    height: 150,
                    child: Text("|||||||"),
                  ),
                  Column(
                    children: [
                      Container(
                        height: 54,
                        width: 50,
                      ),
                      Center(
                        child: Container(
                          height: 30,
                          width: 80,
                          child: Text(
                            "=${sum}",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black38),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 33,
                      ),
                      Center(
                        child: Container(
                          height: 30,
                          width: 80,
                          child: Text(
                            "=${sum}",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Book your ride!"),
                          content: Text("Do you want to book you ride?"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("No")),
                            const SizedBox(
                              width: 5,
                            ),
                            TextButton(
                                onPressed: () async {

                                  setState(() {
                                    load = true;
                                  });

                                  await tokenManager.updateToken(
                                      app.passengerModel.uidp, 'passengers');
                                  AccessTokenFirebase accessTokenGetter =
                                      AccessTokenFirebase();
                                  String token =
                                      await accessTokenGetter.getAccessToken();
                                  print(
                                      "driver Token is ${widget.drivertoken}");

                                  await sendPushMessage(
                                      widget.drivertoken,
                                      app.passengerModel.passengerName,
                                      'Mr ${app.passengerModel.passengerName} booked your car.Click here for more details.');

                                  final newRideKey = passengerRef.push().key;

                                  if (remainingseats == 0) {
                                    DriversHavingPassengerData.child(
                                            app.passengerModel.uidp)
                                        .set({
                                      'deviceToken':
                                          app.passengerModel.deviceToken,
                                      "bio": app.passengerModel.passengerBio,
                                      'passengerName':
                                          app.passengerModel.passengerName,
                                      'passengerPhone': app
                                          .passengerModel.passengerPhoneNumber,
                                      'passengerBookSeats': widget.person,
                                      'gender':
                                          app.passengerModel.passengerGender,
                                      'location': {
                                        'lat': widget.selectedlocation.latitude,
                                        'long':
                                            widget.selectedlocation.longitude
                                      }
                                    }).then((value) {
                                      passengerRef
                                          .child(app.passengerModel.uidp)
                                          .child(newRideKey.toString())
                                          .set({
                                        "date": widget.date,
                                        "location": {
                                          "from": widget.pick1,
                                          "to": widget.drop1,
                                          'lat':
                                              widget.selectedlocation.latitude,
                                          'long':
                                              widget.selectedlocation.longitude
                                        },
                                        "person": widget.person,
                                      });
                                    }).then((value) {
                                      userReference.remove().then((value) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => bookedDetails(
                                              seats: widget.person,
                                              fare: widget.fare,
                                              drop2: widget.drop1,
                                              pick2: widget.pick1,
                                              plateNumber: widget.plateNumber,
                                              make: widget.make,
                                              uid: widget.uid,
                                              color: widget.color,
                                              date2: widget.date,
                                              profileUrl: widget.profileURL,
                                              name: widget.name,
                                              phoneNumber: widget.phoneNumber,
                                              time: widget.time.toString(),
                                              token: widget.drivertoken,
                                            ),
                                          ),
                                        );
                                      });
                                    });
                                  } else if (remainingseats < 0) {
                                    showSnackBar(context,
                                        "There are no more seats available in this car. Please look for another car.");
                                  } else {
                                    DriversHavingPassengerData.child(widget.uid)
                                        .child(app.passengerModel.uidp)
                                        .set({
                                      'passengerName':
                                          app.passengerModel.passengerName,
                                      "bio": app.passengerModel.passengerBio,
                                      'passengerPhone': app
                                          .passengerModel.passengerPhoneNumber,
                                      'passengerBookSeats': widget.person,
                                      'gender':
                                          app.passengerModel.passengerGender,
                                      'deviceToken':
                                          app.passengerModel.deviceToken,
                                      'location': {
                                        'lat': widget.selectedlocation.latitude,
                                        'long':
                                            widget.selectedlocation.longitude
                                      }
                                    }).then((value) {
                                      refrence.child(widget.uid).update(
                                        {
                                          'seats': remainingseats.toString(),
                                        },
                                      );
                                    }).then((value) {
                                      passengerRef
                                          .child(app.passengerModel.uidp)
                                          .child(newRideKey.toString())
                                          .set({
                                        "date": widget.date,
                                        "location": {
                                          "from": widget.pick1,
                                          "to": widget.drop1,
                                          'lat':
                                              widget.selectedlocation.latitude,
                                          'long':
                                              widget.selectedlocation.longitude
                                        },
                                        "person": widget.person,
                                      });
                                    }).then(
                                      (value) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => bookedDetails(
                                              seats: widget.person,
                                              fare: widget.fare,
                                              drop2: widget.drop1,
                                              pick2: widget.pick1,
                                              plateNumber: widget.plateNumber,
                                              make: widget.make,
                                              uid: widget.uid,
                                              color: widget.color,
                                              date2: widget.date,
                                              profileUrl: widget.profileURL,
                                              name: widget.name,
                                              phoneNumber: widget.phoneNumber,
                                              time: widget.time,
                                              token: widget.drivertoken,
                                            ),
                                          ),
                                        );
                                      },
                                    ).onError(
                                      (error, stackTrace) {
                                        showSnackBar(
                                          context,
                                          error.toString(),
                                        );
                                      },
                                    );
                                  }
                                  setState(() {
                                    load = false;
                                  });
                                },
                                child: Text("Yes"))
                          ],
                        );
                      });
                },
                child: load == true
                    ? Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Text(
                        "Book Now",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class bookedDetails extends StatefulWidget {
  final String uid;
  final String pick2;
  final String drop2;
  final String date2;
  final String seats;
  final String fare;
  final String color;
  final String make;
  final String plateNumber;
  final String profileUrl;
  final String name;
  final String phoneNumber;
  final String time;
final String token;
  const bookedDetails({
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
    required this.profileUrl,
    required this.name,
    required this.phoneNumber,
    required this.time, required this.token,

  });

  @override
  State<bookedDetails> createState() => _bookedDetailsState();
}

class _bookedDetailsState extends State<bookedDetails> {
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    Timer(Duration(seconds: 2), () {
      // Navigate to the next page after 3 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AnotherPassengerData(
                  color: widget.color,
                  uid: widget.uid,
                  make: widget.make,
                  plateNumber: widget.plateNumber,
                  pick2: widget.pick2,
                  drop2: widget.drop2,
                  fare: widget.fare,
                  seats: widget.seats,
                  date2: widget.date2,
                  profileURL: widget.profileUrl,
                  name: widget.name,
                  phoneNumber: widget.phoneNumber,
                  time: widget.time,
              token: widget.token,
                )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.red,
          child: Center(
            child: Text(
              "Thank You",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
