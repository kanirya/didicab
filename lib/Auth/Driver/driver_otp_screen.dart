import 'package:didiauth2/Driver/DriverHomeScreen.dart';
import 'package:didiauth2/Auth/Driver/Driver_information_screen.dart';
import 'package:didiauth2/helpers/UiHelpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../helpers/custom.dart';
import '../Provider/Driver_auth_provider.dart';

class DriverOtpScreen extends StatefulWidget {
  final String verificationID;

  const DriverOtpScreen({super.key, required this.verificationID});

  @override
  State<DriverOtpScreen> createState() => _DriverOtpScreenState();
}

class _DriverOtpScreenState extends State<DriverOtpScreen> {
  String? otpcode;

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 35,
                  ),
                  child: ListView(children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                    Container(width: 80,height: 80,child: Icon(FontAwesomeIcons.sortNumericDesc,size: 30,),),
                    const SizedBox(
                      height: 220,
                    ),
                    Center(
                      child: const Text(
                        "Verification",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Enter the OTP send to your phone number.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Pinput(
                      length: 6,
                      showCursor: true,
                      defaultPinTheme: PinTheme(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.redAccent.shade200),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      onCompleted: (value) {
                        setState(() {
                          otpcode = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: CustomButton(
                        text: "Verify",
                        onPressed: () {
                          if (otpcode != null) {
                            verifyOtp(context, otpcode!);
                          } else {
                            showSnackBar(context, "Enter 6-Digits code");
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Didn't receive any code?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    const Text("Resend new code",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ))
                  ]),
                ),
              ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationID,
      userOtp: userOtp,
      onSuccess: () {
        ap.checkExistingUser().then(
          (value) async {
            if (value == true) {
              ap.getDataFromFireStore().then(
                    (value) => ap.saveDriverDataToSP().then(
                          (value) => ap.setSignIn().then(
                                (value) => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NavigationMenu()),
                                    (route) => false),
                              ),
                        ),
                  );
            } else {
              //new user
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DriverInformationScreen()),
                  (route) => false);
            }
          },
        );
      },
    );
  }
}
