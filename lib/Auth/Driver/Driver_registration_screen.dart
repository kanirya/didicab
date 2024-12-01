import 'package:country_picker/country_picker.dart';
import 'package:didiauth2/Auth/Provider/Driver_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../helpers/custom.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final TextEditingController phoneController = TextEditingController();

  Country selectedCountry = Country(
      phoneCode: "92",
      countryCode: "PK",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "Pakistan",
      example: "Pakistan",
      displayName: "Pakistan",
      displayNameNoCountryCode: "PK",
      e164Key: "");

  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneController.text.length));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios,),
                    onPressed: (){
                      Navigator.pop(context);
                    },),
                ),
                Container(height: 80,width: 80,child: Icon(FontAwesomeIcons.lockOpen,size: 30,),),

                const SizedBox(
                  height: 220,
                ),
                Center(
                  child: const Text(
                    "Registration",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Add your phone number. We will send you a verification code",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  cursorColor: Colors.purple,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  onChanged: (value) {
                    setState(() {
                      phoneController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    hintText: "Enter phone number",
                    hintStyle:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: 60,
                        height: 20,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              showCountryPicker(
                                countryListTheme: const CountryListThemeData(
                                    bottomSheetHeight: 500),
                                context: context,
                                onSelect: (value) {
                                  setState(() {
                                    selectedCountry = value;
                                  });
                                },
                              );
                            },
                            child: Text(
                              "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    suffixIcon: phoneController.text.length > 9
                        ? Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 18,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                      text: "Login", onPressed: () => sendPhoneNumber()),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    ap.signInWithPhone(context, "+${selectedCountry.phoneCode}$phoneNumber");
  }
}