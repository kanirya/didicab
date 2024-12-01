import 'package:didiauth2/Auth/Provider/Driver_auth_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverTrips extends StatefulWidget {
  const DriverTrips({super.key});

  @override
  State<DriverTrips> createState() => _DriverTripsState();
}

class _DriverTripsState extends State<DriverTrips> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final tripRef =
        FirebaseDatabase.instance.ref("driverTrips").child(ap.driverModel.uid);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Your Trips",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          backgroundColor: Color(0xffF0F8FF),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(width: 3, color: Colors.black12),
              borderRadius: BorderRadius.circular(12)),
          child: FirebaseAnimatedList(
            query: tripRef,
            itemBuilder: ((context, snapshot, animation, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 3,color: Colors.black26),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: ListTile(
                    onTap: (){},
                    title: Row(
                      children: [
                        Text(
                          "From-- ",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        Container(
                          width: 90,
                          height: 20,
                          child: Text(
                            snapshot
                                .child("location")
                                .child("tripPickLocation")
                                .value
                                .toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          "--To--  ",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        Container(
                          width: 90,
                          height: 20,
                          child: Text(
                            snapshot
                                .child("location")
                                .child("tripDropLocation")
                                .value
                                .toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    subtitle: Column(
                      children: [
                        const SizedBox(height: 3,),
                        Row(
                          children: [
                            const SizedBox(height: 10,),
                            Text(
                              "Date: ",
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                            Container(
                              width: 80,

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xff737CA1),
                              ),
                              child: Center(
                                child: Text(
                                  snapshot.child("tripDate").value.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                              "Fare: ",
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                            Container(
                              width: 50,

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xff737CA1),
                              ),
                              child: Center(
                                child: Text(
                                  snapshot.child("tripFear").value.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Text(
                              "Seats: ",
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                            Container(
                              width: 20,

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xff737CA1),
                              ),
                              child: Center(
                                child: Text(
                                  snapshot.child("tripSeats").value.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ));
  }
}
