import 'package:didiauth2/Auth/Passenger/Passenger_information_screen.dart';
import 'package:didiauth2/Auth/Provider/Driver_auth_provider.dart';
import 'package:didiauth2/Auth/Provider/Passenger_auth_provider.dart';
import 'package:didiauth2/Passenger/Passenger_homeScreen.dart';
import 'package:didiauth2/api/sendNotification.dart';
import 'package:didiauth2/helpers/UiHelpers.dart';
import 'package:didiauth2/helpers/custom.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class passengerOtpScreen extends StatefulWidget {
  final String passengerVerificationId;

  const passengerOtpScreen({super.key, required this.passengerVerificationId});

  @override
  State<passengerOtpScreen> createState() => _passengerOtpScreenState();
}

class _passengerOtpScreenState extends State<passengerOtpScreen> {
  String? otpCodep;

  @override
  Widget build(BuildContext context) {
    final isPassengerLoading =
        Provider.of<AuthProviderPassenger>(context, listen: true)
            .isPassengerLoading;
    return Scaffold(
      body: SafeArea(
        child: isPassengerLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      Icon(FontAwesomeIcons.sortNumericDesc),
                      const SizedBox(
                        height: 235,
                      ),
                      Center(
                        child: const Text(
                          "Verification",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Enter the OTP send to your phone number",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Color(0xffff5757),
                                )),
                            textStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                        onCompleted: (value) {
                          setState(() {
                            otpCodep = value;
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
                            if (otpCodep != null) {
                              verifyOtpP(context, otpCodep!);
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
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  //verify otp
  void verifyOtpP(BuildContext context, String passengerOtp) {
    var tokenManager=TokenManager();

    final app = Provider.of<AuthProviderPassenger>(context, listen: false);
    app.verifyOtpP(
      context: context,
      verificationId: widget.passengerVerificationId,
      passengerOtp: passengerOtp,
      onSuccess: () {
        app.checkExistingUserP().then(
          (value) async {
            if (value == true) {

              //passenger exist in our app
              app.getDataFromFirestore().then(
                    (value) => app.savePassengerDataToSp().then(
                          (value) => app.setSignInP().then((onValue)async{
                            tokenManager.updateToken(app.passengerModel.uidp, 'passengers');
                          }).then(
                                (value) => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NavigationMenuPassenger()),
                                    (route) => false),
                              ),
                        ),
                  );
            } else {
              //new passener
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  PassengerInformationScreen()),
                  (route) => false);
            }
          },
        );
      },
    );
  }
}
