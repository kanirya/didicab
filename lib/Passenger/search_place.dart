import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class passengerMap extends StatefulWidget {
  const passengerMap({super.key});

  @override
  State<passengerMap> createState() => _passengerMapState();
}

class _passengerMapState extends State<passengerMap> {
  TextEditingController _controller = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '123456';
  List<dynamic> _placesList = [];




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      onChange();


    });
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = "AIzaSyDaPCgsgBEA7F4YHSWd0k0Fkm155IxsX-A";
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    print('data');
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception("Failed to load data");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                  controller: _controller,
                  maxLength: 50,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: Colors.purple,
                      size: 29,
                    ),
                    hintText: "Search places with name",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Colors.black38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Colors.black38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _placesList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () async {
                        List<Location> locations = await locationFromAddress(
                            _placesList[index]['description']);
                        print(locations.last.longitude);
                        print(locations.last.latitude);
                      },
                      title: Text(_placesList[index]['description']),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }

}

