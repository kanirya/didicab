import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




Future<String> loadServiceAccount() async {
  try {
    // Try loading using rootBundle (for Flutter)
    return await rootBundle.loadString('assets/didicabauth.json');
  } catch (e) {
    // Fallback to loading from file system (for standalone Dart)
    return await File('assets/didicabauth.json').readAsString();
  }
}

Future<void> sendPushMessage(String token, String title, String body) async {
  // Load the service account credentials
  final jsonString = await loadServiceAccount();

  var accountCredentials = ServiceAccountCredentials.fromJson(jsonString);

  // Define the required scopes
  const _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging'
  ];

  // Obtain an authenticated HTTP client
  var client = await clientViaServiceAccount(accountCredentials, _scopes);

  // Define the message payload
  var message = {
    "message": {
      "token": token,
      "notification": {
        "title": title,
        "body": body
      }
    }
  };

  // Define the Firebase API endpoint
  var url = 'https://fcm.googleapis.com/v1/projects/didi-auth/messages:send';

  // Send the HTTP POST request
  var response = await client.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(message),
  );

  if (response.statusCode == 200) {
    print('Message sent successfully');
  } else {
    print('Failed to send message');
    print(response.body);
  }
}


class TokenManager {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Updates the device token in Firestore for the given user ID.
  ///
  /// The function listens for token refresh events and updates the Firestore
  /// database with the new token. It also sets the initial token if it is available.
  Future<void> updateToken(String userId,String collection) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Listen for token refresh events
    messaging.onTokenRefresh.listen((newToken) async {
      await _saveTokenToDatabase(userId, newToken,collection);
    });

    // Get the initial token and save it to the database
    String? token = await messaging.getToken();
    if (token != null) {
      await _saveTokenToDatabase(userId, token,collection);
    }
  }

  /// Saves the given token to Firestore for the given user ID.
  ///
  /// This private function handles the actual Firestore update.
  Future<void> _saveTokenToDatabase(String userId, String token,String collection) async {
    try {
      await firestore.collection(collection).doc(userId).update({'deviceToken': token});
      print('Token updated for user $userId: $token');
    } catch (e) {
      print('Failed to update token for user $userId: $e');
    }
  }
}




Future<void> sendPushMessages1(List<String> tokens, String title, String body) async {
  // Load the service account credentials
  final jsonString = await loadServiceAccount();
  var accountCredentials = ServiceAccountCredentials.fromJson(jsonString);

  // Define the required scopes
  const _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging'
  ];

  // Obtain an authenticated HTTP client
  var client = await clientViaServiceAccount(accountCredentials, _scopes);

  // Define the Firebase API endpoint
  var url = 'https://fcm.googleapis.com/v1/projects/didi-auth/messages:send';

  for (String token in tokens) {
    // Define the message payload
    var message = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body
        }
      }
    };

    // Send the HTTP POST request
    var response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully to $token');
    } else {
      print('Failed to send message to $token');
      print(response.body);
    }
  }
}
