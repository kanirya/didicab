import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didiauth2/Auth/Driver/Driver_model.dart';
import 'package:didiauth2/Auth/Driver/driver_otp_screen.dart';
import 'package:didiauth2/Driver/Driver_passengerData.dart';
import 'package:didiauth2/helpers/UiHelpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;
  DriverModel? _driverModel;
  DriverModel get driverModel => _driverModel!;
  bool _PDscreen = false;
  bool get PDscreen => _PDscreen;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSign();
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
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
                builder: (context) => DriverOtpScreen(
                  verificationID: verificationId,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  //verify otp

  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);
      User user = (await _firebaseAuth.signInWithCredential(creds)).user!;
      if (user != null) {
        //carry our logic
        _uid = user.uid;

        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

//Database operations
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("drivers").doc(_uid).get();
    if (snapshot.exists) {
      print("Driver Exists");
      return true;
    } else {
      print("new Driver");
      return false;
    }
  }

//save data to firebase
  void saveDriverDatatoFirebase({
    required BuildContext context,
    required DriverModel driverModel,
    required File profilePic,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      //uploading image to firebase storage
      await storeFileToStorage("profilePic/$_uid", profilePic).then((value) {
        driverModel!.profilePic = value;
        driverModel.createdAt =
            DateTime.now().millisecondsSinceEpoch.toString();
        driverModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        driverModel.uid = _firebaseAuth.currentUser!.uid;
      });
      _driverModel = driverModel;

      // uploading to database
      await _firebaseFirestore
          .collection("drivers")
          .doc(_uid)
          .set(driverModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future getDataFromFireStore() async {
    await _firebaseFirestore
        .collection("drivers")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _driverModel = DriverModel(
          name: snapshot['name'],
          phoneNumber: snapshot['phoneNumber'],
          CNIC: snapshot['CNIC'],
          make: snapshot['make'],
          model: snapshot['model'],
          carYear: snapshot['carYear'],
          seats: snapshot['seats'],
          numberPlate: snapshot['numberPlate'],
          carColor: snapshot['carColor'],
          profilePic: snapshot['profilePic'],
          createdAt: snapshot['createdAt'],
          uid: snapshot['uid'],
        deviceToken: snapshot['deviceToken']
      );
      _uid=driverModel.uid;
    });
  }

  //storing data locally
  Future saveDriverDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("driver_model", jsonEncode(driverModel.toMap()));
  }

  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("driver_model") ?? '';
    _driverModel = DriverModel.fromMap(jsonDecode(data));
    _uid = _driverModel!.uid;
    notifyListeners();
  }

  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }

}
