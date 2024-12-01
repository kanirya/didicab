import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didiauth2/Auth/Driver/Driver_model.dart';
import 'package:didiauth2/Auth/Passenger/Passenger_model.dart';
import 'package:didiauth2/Auth/Passenger/passenger_otp_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/UiHelpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthProviderPassenger extends ChangeNotifier {
  bool _isPassengerSignIn = false;

  bool get isPassengerSignIn => _isPassengerSignIn;
  bool _isPassengerLoading = false;

  bool get isPassengerLoading => _isPassengerLoading;
  String? _uidp;

  String get uidp => _uidp!;
  PassengerModel? _passengerModel;

  PassengerModel get passengerModel => _passengerModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  AuthProviderPassenger() {
    checkPassengerSign();
  }

  void checkPassengerSign() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isPassengerSignIn = sp.getBool("is_passengerSignedin") ?? false;
    notifyListeners();
  }

  Future setSignInP() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("is_passengerSignedin", true);
    _isPassengerSignIn = true;
    notifyListeners();
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    passengerOtpScreen(passengerVerificationId: verificationId),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  // Verify otp
  void verifyOtpP(
      {required BuildContext context,
      required String verificationId,
      required String passengerOtp,
      required Function onSuccess}) async {
    _isPassengerLoading = true;
    notifyListeners();
    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: passengerOtp);
      //passenger
      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;
      if (user != null) {
        _uidp = user.uid;
        onSuccess();
      }
      _isPassengerLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isPassengerLoading = false;
      notifyListeners();
    }
  }

  //Data base operations for passenger
  Future<bool> checkExistingUserP() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("passengers").doc(_uidp).get();
    if (snapshot.exists) {
      print("Passenger exists");
      return true;
    } else {
      print("new passenger");
      return false;
    }
  }

  void savePassengerDataToFirebase({
    required BuildContext context,
    required PassengerModel passengerModel,
    required Function onSuccess,
  }) async {
    _isPassengerLoading = true;
    notifyListeners();
    try {
      {
        passengerModel.passengerCreatedAt =
            DateTime.now().toString();
        passengerModel.passengerPhoneNumber =
            _firebaseAuth.currentUser!.phoneNumber!;
        passengerModel.uidp = _firebaseAuth.currentUser!.uid;
      }
      ;
      _passengerModel = passengerModel;

      // uploading to data base
      await _firebaseFirestore
          .collection("passengers")
          .doc(_uidp)
          .set(passengerModel.toMap())
          .then((value) {
        onSuccess();
        _isPassengerLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isPassengerLoading = false;
      notifyListeners();
    }
  }

  Future getDataFromFirestore() async {
    await _firebaseFirestore
        .collection("passengers")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _passengerModel = PassengerModel(
          passengerName: snapshot['passengerName'],
          passengerGender: snapshot['passengerGender'],
          passengerCreatedAt: snapshot['passengerCreatedAt'],
          passengerPhoneNumber: snapshot['passengerPhoneNumber'],
          uidp: snapshot['uidp'],
          passengerBio: snapshot['passengerBio'],
        deviceToken: snapshot['deviceToken']

      );
      _uidp=passengerModel.uidp;
    });
  }

  // Storing data locally

  Future savePassengerDataToSp() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("passenger_model", jsonEncode(passengerModel.toMap()));
  }

  Future getDataFromSPP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String data = sp.getString("passenger_model") ?? '';
    _passengerModel = PassengerModel.fromMap(jsonDecode(data));
    _uidp = _passengerModel!.uidp;
    notifyListeners();
  }




  Future passengerSignOut() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isPassengerSignIn = false;
    notifyListeners();
    sp.clear();
  }
}
