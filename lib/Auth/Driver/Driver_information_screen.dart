import 'package:didiauth2/Auth/Provider/Driver_auth_provider.dart';
import 'package:didiauth2/Global_variables.dart';
import 'package:didiauth2/helpers/UiHelpers.dart';
import 'package:didiauth2/helpers/custom.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:didiauth2/Auth/Driver/Driver_model.dart';
import 'package:didiauth2/Driver/DriverHomeScreen.dart';

class DriverInformationScreen extends StatefulWidget {
  const DriverInformationScreen({super.key});

  @override
  State<DriverInformationScreen> createState() =>
      _DriverInformationScreenState();
}

class _DriverInformationScreenState extends State<DriverInformationScreen> {
  File? image;

  final nameController = TextEditingController();
  final CNICController = TextEditingController();
  final carmakeController = TextEditingController();
  final carModelController = TextEditingController();
  final carYearController = TextEditingController();
  final plateNumberController = TextEditingController();
  final numberOfSeatsController = TextEditingController();
  final carColorController = TextEditingController();
  String? token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTokenPassenger();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    CNICController.dispose();
  }

  // for selecting image
  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 5),
          child: isLoading == true
              ?  Center(
                  child: CircularProgressIndicator(
                    color: mainColor,
                  ),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => selectImage(),
                          child: image == null
                              ?CircleAvatar(
                                  backgroundColor: greyTheme,
                                  radius: 50,
                                  child: Icon(
                                    Icons.account_circle,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundImage: FileImage(image!),
                                  radius: 50,
                                ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          margin: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              //Name
                              textField2(
                                  hintText: "Name",

                                  inputType: TextInputType.text,
                                  controller: nameController),

                              //CNIC
                              textField2(
                                  hintText: "CNIC",

                                  inputType: TextInputType.number,
                                  controller: CNICController),
                              const SizedBox(
                                height: 10,
                              ),
                               Text(
                                "Car Detials",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20,color: greyTheme),
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                              //car make
                              textField2(
                                  hintText: "Car Make(company)",

                                  inputType: TextInputType.text,
                                  controller: carmakeController),

                              //car model
                              textField2(
                                  hintText: "Model name",

                                  inputType: TextInputType.text,
                                  controller: carModelController),

                              //car year
                              textField2(
                                  hintText: "Year",

                                  inputType: TextInputType.number,
                                  controller: carYearController),

                              //no of seats
                              textField2(
                                  hintText: "No of Seats",
                                  inputType: TextInputType.number,
                                  controller: numberOfSeatsController),

                              //number plat
                              textField2(
                                  hintText: "Car Plate number",
                                  inputType: TextInputType.text,
                                  controller: plateNumberController),
                              //car color
                              textField2(
                                  hintText: "Car Colors",
                                  inputType: TextInputType.text,
                                  controller: carColorController),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * .60,
                                child: CustomButton(
                                  onPressed: () => storeData(),
                                  text: "Continue",
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
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

  //store data to database
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    DriverModel driverModel = DriverModel(
        name: nameController.text.trim(),
        phoneNumber: "",
        CNIC: CNICController.text.trim(),
        make: carmakeController.text.trim(),
        model: carModelController.text.trim(),
        carYear: carYearController.text.trim(),
        seats: numberOfSeatsController.text.trim(),
        numberPlate: plateNumberController.text.trim(),
        carColor: carColorController.text.trim(),
        profilePic: "",
        createdAt: "",
        uid: "",
        deviceToken: token.toString()
    );
    if (image != null) {
      ap.saveDriverDatatoFirebase(
        context: context,
        driverModel: driverModel,
        profilePic: image!,
        onSuccess: () {
          // once data is saved we need to store it locally
          ap.saveDriverDataToSP().then(
                (value) => ap.setSignIn().then(
                      (value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NavigationMenu()),
                          (route) => false),
                    ),
              );
        },
      );
    } else {
      showSnackBar(context, "Please upload your profile photo");
    }
  }
}
