import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:didiauth2/Auth/Provider/Driver_auth_provider.dart'; // Adjust this import based on your project structure

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _billingAmount = 0;
  int _totalTrip = 0;

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

    final TotalTrips = await billingRef.child('totalTrips').get();

    if(TotalTrips.exists){
      setState(() {
        _totalTrip= int.parse(TotalTrips.value.toString());
      }
      );
    }else{
      _totalTrip=0;
    }
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

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final walletRef =
        FirebaseDatabase.instance.ref("driverTrips").child(ap.driverModel.uid);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffF0F8FF),
        title: Text(
          "Wallet",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              child: FirebaseAnimatedList(
                query: walletRef,

                itemBuilder: (context, snapshot, animation, index) {
                  return Padding(
                    padding:const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    child: Container(

                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100]
                      ),
                      child: ListTile(
                        title:const Row(
                          children: [
                            Text("Trip Cost",style: TextStyle(fontSize: 19,fontWeight: FontWeight.w800,color: Colors.black),),
                          ],
                        ),
                        subtitle: Column(
                          children: [
                            const SizedBox(
                              height: 3,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Date: ",
                                  style: TextStyle(fontWeight: FontWeight.w400,fontSize: 11),
                                ),
                                Container(
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Color(0xff737CA1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      snapshot.child("tripDate").value.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,fontSize: 11),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                        trailing: Container(
                          width: 90,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color(0xffffe040),
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Center(child: Text("Rs ${snapshot.child('tripCost').value.toString()}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white),)),
                        ),
                      ),

                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 50,
              left: 10,
              child: Container(
                height: 60,
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 170,
                          height: 30,
                          child: Center(
                            child: Text(
                              'Remaining Balance : ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.white,fontSize: 17
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 30,),

                        Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),

                          ),
                          child: Center(
                            child: Text(
                              'Rs ${_billingAmount}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, color: Colors.white,fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 5,

                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Container(

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),color: Color(0xffffe040)),
                      width: 160,
                      height: 40,
                      child: Center(
                        child: Text(
                          "Your Trips =",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white,fontSize: 17),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),color: Colors.grey,
                      ),
                      child: Center(
                        child: Text(
                          '$_totalTrip', // Display the billing amount
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white,fontSize: 17),
                        ),
                      ),
                    )
                  ],
                ),
              ),

          ],
        ),
      ),
    );
  }
}
