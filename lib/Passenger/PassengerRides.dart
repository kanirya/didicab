import 'package:didiauth2/Auth/Provider/Passenger_auth_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class passengerTrips extends StatefulWidget {
  const passengerTrips({super.key});

  @override
  State<passengerTrips> createState() => _passengerTripsState();
}

class _passengerTripsState extends State<passengerTrips> {
  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AuthProviderPassenger>(context, listen: false);
    final tripRef =
    FirebaseDatabase.instance.ref("PassengerTrips").child(app.passengerModel.uidp);
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
                                .child("from")
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
                                .child("to")
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
                                  snapshot.child("date").value.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10,),
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
                                  snapshot.child("person").value.toString(),
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
        )
    );
  }
}
