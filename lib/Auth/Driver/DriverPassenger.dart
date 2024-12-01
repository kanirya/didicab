
import 'package:didiauth2/Auth/Passenger/Passenger_registration_screen.dart';
import 'package:flutter/material.dart';

import '../../helpers/custom.dart';
import 'driver_registration_screen.dart';

class DriverCustomer extends StatefulWidget {
  const DriverCustomer({super.key});

  @override
  State<DriverCustomer> createState() => _DriverCustomerState();
}

class _DriverCustomerState extends State<DriverCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width*.8,
              child: CustomButton(text: "Passenger", onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => passengerRegistrationScreen(),
                  ),
                );

              }),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*.8,
              child: CustomButton(
                  text: "Driver",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverRegisterScreen(),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
