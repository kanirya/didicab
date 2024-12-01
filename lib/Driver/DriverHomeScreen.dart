import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didiauth2/Auth/Provider/Driver_auth_provider.dart';
import 'package:didiauth2/Driver/Driver_passengerData.dart';
import 'package:didiauth2/Driver/profile/Driver_profile.dart';
import 'package:didiauth2/Driver/Driver_trips.dart';
import 'package:didiauth2/Driver/driver_wallet.dart';
import 'package:didiauth2/Global_variables.dart';
import 'package:didiauth2/api/sendNotification.dart';
import 'package:didiauth2/helpers/UiHelpers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int indexSelected = 0;

  onBarItemClicked(int i) {
    setState(() {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          DriverHome(),
          DriverWalletScreen(),
          DriverTrips(),
          driverProfile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedFontSize: 10,
        elevation: 0,
        fixedColor: Colors.black,
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        iconSize: 20,
        selectedFontSize: 11,
        onTap: onBarItemClicked,
        currentIndex: indexSelected,
        backgroundColor: mainColor,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(LineAwesomeIcons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(LineAwesomeIcons.wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.toc), label: "Trips"),
          BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_outlined), label: "Profile"),
        ],
      ),
    );
  }
}

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  var ref;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _billingAmount = 0;
  int _totalTrips = 0;

  @override
  void initState() {
    super.initState();
    final ap = Provider.of<AuthProvider>(context, listen: false);
    fetchBillingAmount(ap.driverModel.uid);
  }

  Future<void> fetchBillingAmount(String uid) async {
    DatabaseReference billingRef =
        FirebaseDatabase.instance.ref("DriverBilling").child(uid);
    final snapshot = await billingRef.child('billingAmount').get();
    final trips = await billingRef.child('totalTrips').get();
    if (trips.exists) {
      setState(() {
        _totalTrips = int.parse(trips.value.toString());
      });
    } else {
      setState(() {
        _totalTrips = 0;
      });
    }
    ;

    if (snapshot.exists) {
      setState(() {
        _billingAmount = int.parse(snapshot.value.toString());
      });
    } else {
      setState(() {
        _billingAmount = 0;
      });
    }
  }

  TextEditingController CommentsController = TextEditingController();
  TextEditingController Farecontroller = TextEditingController();
  DateTime mydate = DateTime.now();
  TimeOfDay? selectedTime;
  String? selectedmode;
  String? selectedSeats;
  String? selectedItem2;
  String? selectedItem1;
  late String? path;
  bool load = false;
  List<String> items1 = ['Parachinar', 'Islamabad', 'Peshawar'];
  List<String> items3 = ['Parachinar'];
  List<String> items2 = ['Islamabad', 'Peshawar'];
  List<String> seats = ['1', '2', '3', '4'];
  List<String> modes = ['Cash', 'Online', 'Both'];

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      setState(() {
        selectedTime = value!;
      });
    });
  }

  void showdatepicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      initialDate: DateTime.now(),
    ).then((value) {
      setState(() {
        mydate = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedItem1 == "Islamabad") {
      ref = FirebaseDatabase.instance
          .ref("FromTo")
          .child('IslamabadToParachinar');
      path = 'IslamabadToParachinar';
    } else if (selectedItem1 == "Parachinar" && selectedItem2 == "Islamabad") {
      ref = FirebaseDatabase.instance
          .ref("FromTo")
          .child('ParachinarToIslamabad');
      path = 'ParachinarToIslamabad';
    } else if (selectedItem1 == "Parachinar" && selectedItem2 == "Peshawar") {
      ref =
          FirebaseDatabase.instance.ref("FromTo").child('ParachinarToPeshawar');
      path = 'ParachinarToPeshawar';
    } else if (selectedItem1 == "Peshawar") {
      ref =
          FirebaseDatabase.instance.ref("FromTo").child('PeshawarToParachinar');
      path = 'PeshawarToParachinar';
    }

    final ap = Provider.of<AuthProvider>(context, listen: false);
    final tripsRef = FirebaseDatabase.instance.ref("driverTrips");
    final billingRef = FirebaseDatabase.instance.ref('DriverBilling');
    final tokenManager = TokenManager();
    return Scaffold(
      body: load == true
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xffff5757),
              ),
            )
          : ListView(
              children: [
                const SizedBox(
                  height: 140,
                ),
                Center(
                  child: Container(
                    width: 340,
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.symmetric(),
                      borderRadius: BorderRadius.circular(12),
                      //  color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 17,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: 40,
                              height: 30,
                              //  color: Colors.red,
                              child: const Text(
                                "Pick",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 10,
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              height: 30,
                              //  color: Colors.red,
                              width: 10,
                              child: const Icon(
                                Icons.circle_outlined,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Container(
                              height: 30,
                              width: 210,
                              color: Colors.grey[200],
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    color: Colors.grey[200],
                                  ),
                                  Container(
                                    width: 140,
                                    height: 30,
                                    child: DropdownButton<String>(
                                      value: selectedItem1,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedItem1 = newValue!;
                                          // If selectedItem1 is Parachinar, set selectedItem2 to the first item in items2
                                          // Otherwise, set selectedItem2 to the first item in items3
                                          selectedItem2 =
                                              (selectedItem1 == 'Parachinar')
                                                  ? items2.first
                                                  : items3.first;
                                        });
                                      },
                                      icon: const Icon(Icons.arrow_drop_down),
                                      // Custom dropdown icon
                                      iconSize: 0,
                                      // Adjust icon size
                                      elevation: 8,
                                      // Dropdown elevation

                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black, // Text color
                                      ),
                                      underline: Container(
                                        // Remove underline
                                        height: 2,
                                        color: Colors.transparent,
                                      ),
                                      items: items1.map((String item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 17,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: 40,
                              height: 30,
                              // color: Colors.red,
                              child: const Text(
                                "Drop",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 10,
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              height: 30,
                              //   color: Colors.red,
                              width: 10,
                              child: const Icon(
                                Icons.circle_outlined,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Container(
                                height: 30,
                                width: 210,
                                color: Colors.grey[200],
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      color: Colors.grey[200],
                                    ),
                                    Container(
                                      width: 140,
                                      height: 25,
                                      child: DropdownButton<String>(
                                          value: selectedItem2,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedItem2 = newValue!;
                                            });
                                          },
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          // Custom dropdown icon
                                          iconSize: 0,
                                          // Adjust icon size
                                          elevation: 8,
                                          // Dropdown elevation
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors
                                                .black, // Text color// Text weight
                                          ),
                                          underline: Container(
                                            // Remove underline
                                            height: 2,
                                            color: Colors.transparent,
                                          ),
                                          items: selectedItem1 == "Parachinar"
                                              ? items2.map((String item) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  );
                                                }).toList()
                                              : items3.map((String item) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  );
                                                }).toList()),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 30,
                              width: 110,
                              //    color: Colors.red,
                            ),
                            Container(
                              width: 90,
                              height: 30,
                              //  color: Colors.green,
                              child: const Text(
                                "Date",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                            Container(
                              width: 90,
                              height: 30,
                              // color: Colors.green,
                              child: const Text(
                                "Seats",
                                style: TextStyle(fontSize: 20),
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
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: _showTimePicker,
                              child: Container(
                                height: 25,
                                width: 85,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Text(
                                    selectedTime == null
                                        ? "Select Time"
                                        : selectedTime!
                                            .format(context)
                                            .toString(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 100,
                              height: 25,
                              color: Colors.grey[200],
                              child: GestureDetector(
                                onTap: () {
                                  showdatepicker();
                                },
                                child: Center(
                                  child: Text(
                                    "${mydate.day}/${mydate.month}/${mydate.year}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Container(
                              width: 70,
                              height: 25,
                              color: Colors.grey[200],
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Container(
                                    width: 50,
                                    height: 20,
                                    child: DropdownButton<String>(
                                      value: selectedSeats,

                                      icon: const Icon(Icons.arrow_drop_down),
                                      // Custom dropdown icon
                                      iconSize: 0,
                                      // Adjust icon size
                                      elevation: 8,
                                      // Dropdown elevation

                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black, // Text color
                                        fontWeight:
                                            FontWeight.bold, // Text weight
                                      ),
                                      underline: Container(
                                        // Remove underline
                                        height: 2,
                                        color: Colors.transparent,
                                      ),
                                      items: seats.map((String item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Center(
                                            child: Text(
                                              item,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? item) {
                                        setState(() {
                                          selectedSeats = item!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 30,
                              width: 110,
                              //    color: Colors.red,
                            ),
                            Container(
                              width: 90,
                              height: 30,
                              //  color: Colors.green,
                              child: const Text(
                                "Fare",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                            Container(
                              width: 90,
                              height: 30,
                              // color: Colors.green,
                              child: const Text(
                                "Mode",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        //    const SizedBox(height: 10,),
                        Row(
                          children: [
                            Container(
                              height: 30,
                              width: 110,
                              // Left spacer container
                            ),
                            Container(
                              width: 100,
                              height: 30,
                              // Adjust the height to match the TextFormField
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 30,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Text(
                                        "PKR",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // Adjusted the height to 30
                                    height: 30,
                                    width: 57,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: TextFormField(
                                        textAlign: TextAlign.center,
                                        controller: Farecontroller,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Container(
                              width: 80,
                              height: 30,
                              color: Colors.grey[200],
                              child: Center(
                                child: DropdownButton<String>(
                                  value: selectedmode,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  iconSize: 0,
                                  elevation: 8,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.transparent,
                                  ),
                                  items: modes.map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? item) {
                                    setState(() {
                                      selectedmode = item!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 20,
                              width: 240,
                              // color: Colors.red,
                              child:
                                  const Text("Additional Comments (optional)"),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 65,
                              width: 315,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(width: 1)),
                              child: TextFormField(
                                controller: CommentsController,
                                maxLines: 5,
                                cursorWidth: 1,
                                style: const TextStyle(fontSize: 13),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 14,
                        ),

                        // Last Button
                        GestureDetector(
                          onTap: () async {
                            await tokenManager.updateToken(
                                ap.driverModel.uid, 'drivers');

                            if (selectedItem2 == null &&
                                selectedItem1 == null) {
                              showSnackBar(context,
                                  "Please Enter Pick And Drop Location");
                            } else if (selectedTime == null) {
                              showSnackBar(context, "Please Enter Time");
                            } else if (selectedSeats == null) {
                              showSnackBar(context,
                                  "Choose how much seats do you have.");
                            } else if (Farecontroller.text.isEmpty) {
                              showSnackBar(context, "Please Enter Fare");
                            }

                            final int fare =
                                int.parse(Farecontroller.text.toString());
                            final int seats =
                                int.parse(selectedSeats.toString());
                            final int total =
                                (((fare * seats) / 100) * 3).round();
                            _billingAmount = _billingAmount + total;
                            _totalTrips = _totalTrips + 1;

                            if (selectedItem2 != null &&
                                selectedItem1 != null &&
                                selectedSeats != null &&
                                Farecontroller.text.isNotEmpty &&
                                selectedTime != null) {

                            DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('rides').child(ap.driverModel.uid);
                            rideRef.update({'rideStatus': 'notstarted'});
                              setState(() {
                                load = true;
                              });
                              ref.child(ap.driverModel.uid).set({
                                "deviceToken": ap.driverModel.deviceToken,
                                "DriverPhoneNumber": ap.driverModel.phoneNumber,
                                "name": ap.driverModel.name,
                                "time":
                                    selectedTime!.format(context).toString(),
                                "CNIC": ap.driverModel.CNIC,
                                "make": ap.driverModel.make,
                                "carColor": ap.driverModel.carColor,
                                "carYear": ap.driverModel.carYear,
                                "numberPlate": ap.driverModel.numberPlate,
                                "seats": selectedSeats.toString(),
                                "comments": CommentsController.text.toString(),
                                "fear": Farecontroller.text.toString(),
                                "pick": selectedItem1,
                                "drop": selectedItem2,
                                "uid": ap.driverModel.uid,
                                "profilePic": ap.driverModel.profilePic,
                                "date":
                                    "${mydate.day.toString()}/${mydate.month.toString()}",
                              }).then((value) {
                                final newRideKey = tripsRef.push().key;
                                tripsRef
                                    .child(ap.driverModel.uid)
                                    .child(newRideKey.toString())
                                    .set({
                                  "tripCost": total,
                                  "tripDate":
                                      "${mydate.day}/${mydate.month}/${mydate.year}",
                                  "location": {
                                    "tripPickLocation": selectedItem1,
                                    "tripDropLocation": selectedItem2,
                                  },
                                  "tripSeats": selectedSeats.toString(),
                                  "tripFear": Farecontroller.text.toString(),
                                });
                              }).then((value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => driverPassengerData(
                                      uid: ap.driverModel.uid,
                                      seats: selectedSeats.toString(),
                                      date2:
                                          "${mydate.day}-${mydate.month}-${mydate.year}",
                                      fare: Farecontroller.text.toString(),
                                      drop2: selectedItem2.toString(),
                                      pick2: selectedItem1.toString(),
                                      color: ap.driverModel.carColor,
                                      plateNumber: ap.driverModel.numberPlate,
                                      make: ap.driverModel.make,
                                      ref: ref,
                                      time: selectedTime!
                                          .format(context)
                                          .toString(),
                                      path: path.toString(),
                                    ),
                                  ),
                                ).then((value) {
                                  billingRef.child(ap.driverModel.uid).update(
                                      {'billingAmount': _billingAmount});
                                  billingRef
                                      .child(ap.driverModel.uid)
                                      .update({'totalTrips': _totalTrips});
                                })

                                .then((value){
                                  setState(() {
                                    load = false;
                                  });
                                });
                              }).onError((error, stackTrace) {
                                showSnackBar(context, error.toString());
                              });
                            }
                          },
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: mainColor,
                            ),
                            child: const Center(
                                child:  Text(
                              "Offer a Ride",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}

void showTimePickerDialog(
    BuildContext context, Function(TimeOfDay) onTimeSelected) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (pickedTime != null) {
    onTimeSelected(pickedTime);
  }
}
