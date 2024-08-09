import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/select_whereto_loc.dart';
import 'package:iu_nav_bus/stu_map_screen.dart';

class StudentDecision extends StatefulWidget {
  const StudentDecision({Key? key}) : super(key: key);

  @override
  State<StudentDecision> createState() => _StudentDecisionState();
}

class _StudentDecisionState extends State<StudentDecision> {
  late LatLng _currentUserPosition;

  @override
  void initState() {
    super.initState();
    // Call functions to load user data and wait for 5 seconds
    loadUserData();
    waitForFiveSec();
  }

  // Function to get user's current location
  Future<void> loadUserData() async {
    await getUserCurrentLocation();
  }

  // Function to wait for 5 seconds
  void waitForFiveSec() {
    Future.delayed(const Duration(seconds: 35), () {
      debugPrint("5 sec wait done");
    });
  }

  // Function to get user's current location
  Future<void> getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentUserPosition = LatLng(position.latitude, position.longitude);
        print(("Current location is $_currentUserPosition"));
        updateCurrentUserLocation(
            context, currentUserEmail, position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0), // Set the height of the app bar
        child: Container(
          margin: const EdgeInsets.only(top: 0), // Adjust the top margin here
          child: AppBar(
            title: const Text(
              "Select Your Destination",
              style:
                  TextStyle(color: Colors.white), // Set the text color to white
            ),
            backgroundColor: const Color.fromARGB(
                255, 72, 80, 155), // Set the color to #0014CA
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white), // Set the back arrow color to white
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(
                    30), // Set the bottom border radius to create a rectangular shape
              ),
            ),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 0), // Adjust the top margin here
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff23e1d4),
              Color(0xff7499c8),
              Color(0xff74accd),
            ],
            stops: [0, 0.5, 1],
            begin: Alignment(-0.0, -1.0),
            end: Alignment(-0.0, 0.9),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 10.0), // Adjust the padding here
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Button for "From University to Home"
              buildButton(
                text: "From University to Home",
                onTap: () async {
                  studentFromLatLng = uniLatLng;
                  studentFromLoc = uniName;
                  setState(() {});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentWhereToLocationSearch(),
                    ),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                width: MediaQuery.sizeOf(context).width * 1,
                child: GestureDetector(
                  onTap: () => launchURL(
                      'https://admissions.iqra.edu.pk/Admission/Admissions/AdmissionForm/1'),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(30), // Same radius as container
                    child: Image.network(ad1),
                  ),
                ),
              ),
              // Button for "From Home to University"
              buildButton(
                text: "From Home to University",
                onTap: () async {
                  studentWhereToLoc = uniName;
                  studentWhereTOLatLong = uniLatLng;
                  studentFromLatLng = _currentUserPosition;
                  List<Placemark> placemarks = await placemarkFromCoordinates(
                    _currentUserPosition.latitude,
                    _currentUserPosition.longitude,
                  );
                  studentFromLoc =
                      "${placemarks.last.thoroughfare} ${placemarks.last.subLocality}";
                  log(placemarks.toString());
                  log(placemarks.last.thoroughfare.toString() +
                      placemarks.last.subLocality.toString());
                  debugPrint("From Home to University");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentMapScreen(
                        needDriverLatLng: _currentUserPosition,
                        userLatLngformarker: _currentUserPosition,
                        fromlatlng: _currentUserPosition,
                        tolatlng: uniLatLng,
                        fromUniToHome: false,
                      ),
                    ),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build reusable button widget
  Widget buildButton({required String text, required VoidCallback onTap}) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 80,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
