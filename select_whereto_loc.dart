import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iu_nav_bus/config.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/stu_whereto_map.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class StudentWhereToLocationSearch extends StatefulWidget {
  const StudentWhereToLocationSearch({super.key});

  @override
  State<StudentWhereToLocationSearch> createState() =>
      _StudentWhereToLocationSearchState();
}

class _StudentWhereToLocationSearchState
    extends State<StudentWhereToLocationSearch> {
  TextEditingController _controller = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = "12345";
  List<dynamic> _placesList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      onChangeSearchValue();
    });
  }

  void onChangeSearchValue() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  Future<void> getSuggestion(String input) async {
    String kPLACES_API_KEY = gplacesAPIKey;
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Where To"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              decoration:
                  const InputDecoration(hintText: "Where you wanna Go?"),
            ),
            Expanded(
                child: ListView.builder(
              itemCount: _placesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    List<Location> locations = await locationFromAddress(
                        _placesList[index]['description']);
                    debugPrint(locations.last.latitude.toString());
                    debugPrint(locations.last.longitude.toString());

                    setState(() {
                      studentWhereTOLatLong = LatLng(
                          locations.last.latitude, locations.last.longitude);
                      studentWhereToLoc =
                          _placesList[index]['description'].toString();
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentWheretoMapScreen(
                                selectedLocation: studentWhereTOLatLong,
                              )),
                    );
                  },
                  title: Text(_placesList[index]['description']),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
