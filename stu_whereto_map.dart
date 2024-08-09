import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/stu_map_screen.dart';

class StudentWheretoMapScreen extends StatefulWidget {
  final LatLng selectedLocation;

  const StudentWheretoMapScreen({super.key, required this.selectedLocation});

  @override
  State<StudentWheretoMapScreen> createState() =>
      _StudentWheretoMapScreenState();
}

class _StudentWheretoMapScreenState extends State<StudentWheretoMapScreen> {
  Completer<GoogleMapController> _controller = Completer();

  late LatLng wheretolatlong;
  late String wheretotext;
  static final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(
          studentWhereTOLatLong.latitude, studentWhereTOLatLong.longitude),
      zoom: 14);

  List<Marker> _marker = [];
  final List<Marker> _list = [];

  moveToCurrentUserLocation() async {
    _marker.add(
      Marker(
          markerId: MarkerId("Where To"),
          position: LatLng(widget.selectedLocation.latitude,
              widget.selectedLocation.longitude),
          infoWindow: const InfoWindow(title: "You Are Here")),
    );
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(
          widget.selectedLocation.latitude, widget.selectedLocation.longitude),
      zoom: 20,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    wheretolatlong = studentWhereTOLatLong;
    wheretotext = studentWhereToLoc;
    _marker.addAll(_list);
    moveToCurrentUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                  markers: Set<Marker>.of(_marker),
                  initialCameraPosition: _kGooglePlex,
                  mapType: MapType.normal,
                  compassEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  }),
            ),
            Container(
              height: MediaQuery.sizeOf(context).height * 0.1,
              width: MediaQuery.sizeOf(context).width * 1,
              color: Colors.green,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentMapScreen(
                              fromlatlng: uniLatLng,
                              needDriverLatLng: uniLatLng,
                              tolatlng: wheretolatlong,
                              userLatLngformarker: wheretolatlong,
                              fromUniToHome: true,
                            )),
                  );
                },
                child: const Center(
                    child: Text(
                  "Confirm Drop off Location?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
