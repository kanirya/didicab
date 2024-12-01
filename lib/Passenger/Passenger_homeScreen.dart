import 'package:didiauth2/Global_variables.dart';
import 'package:didiauth2/Passenger/Drivers_list.dart';
import 'package:didiauth2/Passenger/Maps_passenger.dart';
import 'package:didiauth2/Passenger/PassengerRides.dart';
import 'package:didiauth2/Passenger/profile/Passenger_profile.dart';
import 'package:didiauth2/api/access_token.dart';
import 'package:didiauth2/helpers/UiHelpers.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../api/sendNotification.dart';
import 'Unknown.dart';


class NavigationMenuPassenger extends StatefulWidget {
  const NavigationMenuPassenger({super.key});

  @override
  State<NavigationMenuPassenger> createState() =>
      _NavigationMenuPassengerState();
}

class _NavigationMenuPassengerState extends State<NavigationMenuPassenger>
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
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          PassengerHome(),
          unknown(),
          passengerTrips(),
          PassengerProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedFontSize: 10,
        elevation: 0,
        fixedColor: Colors.black,
        showSelectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        iconSize: 20,
        selectedFontSize: 11,
        onTap: onBarItemClicked,
        currentIndex: indexSelected,
        backgroundColor: Colors.red,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_max), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
          BottomNavigationBarItem(
              icon: Icon(Icons.toc_rounded), label: "Trips"),
          BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_outlined), label: "Profile"),
        ],
      ),
    );
  }
}

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  TextEditingController CommentsController = TextEditingController();
  TextEditingController Farecontroller = TextEditingController();
  DateTime _dateTime = DateTime.now();

  String? selectedPerson;
  String? selectedItem2;
  String? selectedItem1;
  LatLng? selectedLocation;
  bool load=false;


  List<String> items1 = ['Parachinar', 'Islamabad', 'Peshawar'];
  List<String> items3 = ['Parachinar'];
  List<String> items2 = ['Islamabad', 'Peshawar'];
  List<String> person = ['1', '2', '3', '4'];

  void showdatepicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    ).then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
  }
  Future<void> _navigateToMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => const PassengerMap(),
      ),
    );
    if (result != null) {
      setState(() {
        selectedLocation = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            const SizedBox(
              height: 190,
            ),
            Center(
              child: Container(
                width: 340,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
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
                          child: Text(
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
                          child: Icon(
                            Icons.circle_outlined,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          height: 30,
                          width: 30,
                          color: Colors.grey[200],
                        ),
                        Container(
                          height: 30,
                          width: 180,
                          color: Colors.grey[200],
                          child: DropdownButton<String>(
                            value: selectedItem1,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedItem1 = newValue!;
                                // If selectedItem1 is Parachinar, set selectedItem2 to the first item in items2
                                // Otherwise, set selectedItem2 to the first item in items3
                                selectedItem2 = (selectedItem1 == 'Parachinar')
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
                              fontSize: 20,
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
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
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
                          child: Text(
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
                          child: Icon(
                            Icons.circle_outlined,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          height: 30,
                          width: 30,
                          color: Colors.grey[200],
                        ),
                        Container(
                          height: 30,
                          width: 180,
                          color: Colors.grey[200],
                          child: DropdownButton<String>(
                            value: selectedItem2,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedItem2 = newValue!;
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
                              color: Colors.black, // Text color// Text weight
                            ),
                            underline: Container(
                              // Remove underline
                              height: 2,
                              color: Colors.transparent,
                            ),
                            items: selectedItem1 == "Parachinar"
                                ? items2.map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList()
                                : items3.map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 25,
                          width: 20,
                        ),
                        Container(
                          height: 35,
                          width: 110,
                          child: ElevatedButton(
                            onPressed: _navigateToMap,
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              backgroundColor:
                              MaterialStateProperty.all<Color>(mainColor),
                            ),
                            child: Text(
                              "Your location",
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    //    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Container(
                          height: 28,
                          width: 60,
                        ),
                        Container(
                          height: 35,
                          width: 50,
                          // color: Colors.green,
                          child: Icon(
                            LineAwesomeIcons.calendar_with_day_focus,
                            size: 35,
                          ),
                        ),
                        Container(
                          width: 110,
                          height: 26,
                          color: Colors.grey[200],
                          child: GestureDetector(
                            onTap: () {
                              showdatepicker();
                            },
                            child: Center(
                              child: Text(
                                "${_dateTime.day.toString()}/${_dateTime.month.toString()}/${_dateTime.year.toString()}",
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          width: 30,
                          height: 45,
                          child: const Icon(
                            Icons.man,
                            size: 45,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 10,
                          height: 26,
                          color: Colors.grey[200],
                        ),
                        Container(
                          width: 50,
                          height: 26,
                          color: Colors.grey[200],
                          child: DropdownButton<String>(
                            value: selectedPerson,
                            dropdownColor: Colors.grey[200],
                            elevation: 8,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black, // Text color// Text weight
                            ),
                            underline: Container(
                              // Remove underline
                              height: 2,
                              color: Colors.transparent,
                            ),
                            items: person.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? item) {
                              setState(() {
                                selectedPerson = item!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    // Last Button
                    GestureDetector(
                      onTap: ()async {
                        if (selectedItem1 != null &&
                            selectedItem2 != null &&
                            selectedPerson != null&&
                        selectedLocation!=null
                        ) {
                          setState(() {
                            load=true;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => driverList(
                                drop: selectedItem2,
                                pick: selectedItem1,
                                person: selectedPerson,
                                selectedlocation: selectedLocation as LatLng,
                                time: _dateTime,
                              ),
                            ),
                          );
                          setState(() {
                            load=false;
                          });
                        } else {
                          showSnackBar(context, "Please Enter Details");
                        }
                        ;
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: mainColor,
                        ),
                        child: Center(
                          child:load==true? const
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ):const Text(
                            "Find a Ride",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
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
