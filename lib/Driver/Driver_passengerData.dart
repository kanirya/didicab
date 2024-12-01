import 'package:didiauth2/Driver/Google_map_driver.dart';

import 'package:didiauth2/api/sendNotification.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Global_variables.dart';

class driverPassengerData extends StatefulWidget {
  final String uid;
  final String pick2;
  final String drop2;
  final String date2;
  final String seats;
  final String fare;
  final String color;
  final String make;
  final String plateNumber;
  final DatabaseReference ref;
  final String time;
  final String path;

  const driverPassengerData({
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
    required this.ref,
    required this.time, required this.path,
  });

  @override
  State<driverPassengerData> createState() => _driverPassengerDataState();
}

class _driverPassengerDataState extends State<driverPassengerData> {
  late String _uid;

  double _total = 1;
  int _totalPerson = 0;
  late double _fare;
  final List<String> passengerFcmTokens = [];
  List name=[];
  List phone=[];
  List<LatLng> coordinateList = [];
  late LatLng droplocation;
  bool load=false;




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _saveState();
    _uid = widget.uid;
    _fare = double.parse(widget.fare);
  }


  Future<void> _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('page1', 'driverPassengerData');
    await prefs.setString('uidd', widget.uid);
    await prefs.setString('pick2d', widget.pick2);
    await prefs.setString('drop2d', widget.drop2);
    await prefs.setString('date2d', widget.date2);
    await prefs.setString('seatsd', widget.seats);
    await prefs.setString('fared', widget.fare);
    await prefs.setString('colord', widget.color);
    await prefs.setString('maked', widget.make);
    await prefs.setString('plateNumberd', widget.plateNumber);
    await prefs.setString('refd', widget.path);
    await prefs.setString('timed', widget.time);
  }

  Future<void> _clearState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('page1');
    await prefs.remove('uidd');
    await prefs.remove('pick2d');
    await prefs.remove('drop2d');
    await prefs.remove('date2d');
    await prefs.remove('seatsd');
    await prefs.remove('fared');
    await prefs.remove('colord');
    await prefs.remove('maked');
    await prefs.remove('plateNumberd');
    await prefs.remove('refd');
    await prefs.remove('timed');
  }

  Future<void> _startRide(DatabaseReference driverRef) async {
    setState(() {
      load=true;
    });
    await _clearState();
    print("passengerFcmTokens: $passengerFcmTokens");
    await sendPushMessages1(
      passengerFcmTokens,
      "On the way",
      "Your driver has started the ride.",
    );
    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('rides').child(_uid);
    rideRef.update({'rideStatus': 'started'});
    await driverRef.remove();
    if (!mounted) return; // Ensure widget is still mounted
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapDriver(
          name: name,
          phoneNumber: phone,
          dropLocation: widget.drop2,
          drop: droplocation,
          dropLatLng: coordinateList,
          uid: widget.uid,
        ),
      ),
    ).then((value){
      setState(() {
        load=false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    if(widget.drop2=='Parachinar'){
      droplocation=LatLng(33.897037, 70.104586);
    }
    else if(widget.drop2=='Islamabad'){
      droplocation=LatLng(33.662898, 73.084721);

    }
    else if(widget.drop2=='Peshawar'){

      droplocation=LatLng(34.008265, 71.569007);
    }
    final passengerRef =
        FirebaseDatabase.instance.ref("DriversHavingPassengerData").child(_uid);
    final DatabaseReference DriverRef = widget.ref.child(widget.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Offered Ride Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                      Container(height: 15,width: 80,child: Text(widget.time,style: TextStyle(fontSize: 12),),)
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
                          top: 80,
                          left: 10,
                          child: const Text(
                            "Seats",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black38),
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
                          top: 10,
                          left: 15,
                          child: Container(
                            width: 42,
                            height: 42,
                            child: SvgPicture.asset('assets/images/Car Details.svg',)
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
                            )),
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
                              width: 110,
                              child: const Center(
                                child: Text(
                                  "Customers List",
                                  style: TextStyle(
                                      fontSize: 15,
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
                              return ListTile(
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
                                trailing: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    LineAwesomeIcons.what_s_app,
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                ),
                                subtitle: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              LineAwesomeIcons.phone,
                                              size: 14,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 80,
                                          height: 15,
                                          child: Text(
                                            snapshot
                                                .child("passengerPhone")
                                                .value
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),

                                      ],
                                    ),
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
                                                  fontWeight: FontWeight.bold),
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
                                                  fontWeight: FontWeight.w800),
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
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
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Container(
                  height: 20,
                  width: 120,
                  child: Text(
                    "Billing Details",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(width: 3, color: Colors.black12),
                  borderRadius: BorderRadius.circular(12)),
              child: FirebaseAnimatedList(
                query: passengerRef,
                itemBuilder: ((context, snapshot, animation, index) {
                  passengerFcmTokens.add(snapshot.child('deviceToken').value.toString());
                    double latitude = double.parse(snapshot.child('location').child('lat').value.toString()) ;
                    double longitude = double.parse(snapshot.child('location').child('long').value.toString()) ;

                    // Create LatLng object and add it to the latLngList
                    LatLng latLng = LatLng(latitude, longitude);
                    coordinateList.add(latLng);
                  name.add(snapshot.child('passengerName').value.toString());
                  phone.add(snapshot.child('passengerPhone').value.toString());
                  int _person = int.parse(
                      snapshot.child('passengerBookSeats').value.toString());
                  _totalPerson = _totalPerson + _person;
                  _total = _person * _fare;
                  return Container(
                    height: 22,
                    child: ListTile(
                      title: Row(
                        children: [
                          Container(
                            width: 90,
                            height: 20,
                            child: Text(
                              snapshot.child('passengerName').value.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                  color: Colors.black54),
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Text(
                            widget.fare,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                                color: Colors.black54),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Text(
                            _person.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                                color: Colors.black54),
                          ),
                          const SizedBox(
                            width: 60,
                          ),
                          Text(
                            "${_total}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .7,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: ()async {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Start Ride"),
                          content: Text("Do you want to start ride?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();                               },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _startRide(DriverRef);
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        );
                      });


                    },
                    child:load==true?
                        Container(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,


                          ),
                        ): Text(
                      "Start Ride",
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
