import 'package:didiauth2/Auth/Passenger/Passenger_model.dart';
import 'package:didiauth2/Auth/Provider/Passenger_auth_provider.dart';
import 'package:didiauth2/helpers/UiHelpers.dart';
import 'package:didiauth2/helpers/custom.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Passenger/Passenger_homeScreen.dart';

class PassengerInformationScreen extends StatefulWidget {
  const PassengerInformationScreen({super.key});

  @override
  State<PassengerInformationScreen> createState() =>
      _PassengerInformationScreenState();
}

class _PassengerInformationScreenState
    extends State<PassengerInformationScreen> {
  final passengerNameController = TextEditingController();
  String? passengerGenderController;
  final bioController = TextEditingController();
  String? token;

  @override
  void initState() {
    super.initState();
    getTokenPassenger();
  }

  @override
  void dispose() {
    super.dispose();
    passengerNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPassengerLoading =
        Provider.of<AuthProviderPassenger>(context, listen: true)
            .isPassengerLoading;
    return Scaffold(
      body: SafeArea(
        child: isPassengerLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.purple,
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 25),
          child: Column(
            children: [
              const SizedBox(
                height: 220,
              ),
              Row(
                children: [
                  Container(
                    height: 30,
                    width: 70,
                  ),
                  Container(
                    height: 30,
                    width: 61,
                    child: const Text(
                      "Name",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black54),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 210,
                    child: TextFormField(
                      controller: passengerNameController,
                      style: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 16),
                      cursorColor: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 70,
                  ),
                  Container(
                    width: 71,
                    height: 30,
                    child: const Text(
                      "I am",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black54),
                    ),
                  ),
                  Container(
                    child: const Text(
                      "Male",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 50,
                    child: Radio(
                        value: "Male",
                        groupValue: passengerGenderController,
                        onChanged: (value) {
                          setState(() {
                            passengerGenderController = value.toString();
                          });
                        }),
                  ),
                  Container(
                    child: const Text(
                      "Female",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 50,
                    child: Radio(
                      value: "Female",
                      groupValue: passengerGenderController,
                      onChanged: (value) {
                        setState(
                              () {
                            passengerGenderController = value.toString();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 30,
                width: 140,
                child: const Center(
                  child: Text(
                    "What do you do? [Optional]",
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 100,
                  ),
                  Container(
                    width: 230,
                    height: 90,
                    child: TextFormField(
                      controller: bioController,
                      maxLength: 100,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * .7,
                child: CustomButton(
                  text: "Continue",
                  onPressed: () => storeDataP(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getTokenPassenger() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      String? token1 = await messaging.getToken();
      setState(() {
        token = token1;
      });
      print("Device Token: $token");
    } catch (e) {
      print("Failed to get device token: $e");
    }
  }

  void storeDataP() {
    if (passengerNameController.text.trim().isEmpty || passengerGenderController == null) {
      showSnackBar(context, "Please fill all required fields");
      return;
    }

    final app = Provider.of<AuthProviderPassenger>(context, listen: false);
    PassengerModel passengerModel = PassengerModel(
      passengerName: passengerNameController.text.trim(),
      passengerGender: passengerGenderController!,
      passengerBio: bioController.text.trim(),
      passengerCreatedAt: "",
      passengerPhoneNumber: "",
      uidp: "",
      deviceToken: token ?? "",
    );

    app.savePassengerDataToFirebase(
      context: context,
      passengerModel: passengerModel,
      onSuccess: () {
        app.savePassengerDataToSp().then(
              (value) => app.setSignInP().then(
                (value) => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationMenuPassenger(),
              ),
                  (route) => false,
            ),
          ),
        );
      },
    );
  }
}
