// ignore_for_file: prefer_const_constructors, prefer_final_fields, avoid_print, prefer_const_declarations, unused_local_variable

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iu_nav_bus/config.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/main.dart';

class DriverRouteScreen extends StatefulWidget {
  final String driverRoute;
  const DriverRouteScreen({super.key, required this.driverRoute});

  @override
  State<DriverRouteScreen> createState() => _DriverRouteScreenState();
}

class _DriverRouteScreenState extends State<DriverRouteScreen> {
  LatLng _currentUserPosition = LatLng(30, 30);
  final Completer<GoogleMapController> _controller = Completer();

  Uint8List? busIcon;
  Map<PolylineId, Polyline> polylines = {};

  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(37.4, -122), zoom: 14);

  List<Marker> _marker = [];
  final List<Marker> _list = [];

  // function to get custom icon
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  moveToCurrentUserLocation() {
    getUserCurrentLocation().then((value) async {
      // _marker.add(
      //   Marker(
      //       markerId: MarkerId("Student"),
      //       position: LatLng(
      //           _currentUserPosition.latitude, _currentUserPosition.longitude),
      //       infoWindow: const InfoWindow(title: "You Are Here")),
      // );
      for (var user in onlineUsers) {
        _marker.add(
          Marker(
            markerId:
                MarkerId(user['email']), // Use the user's email as marker ID
            position: LatLng(user['currentLocationlat'],
                user['currentLocationlng']), // User's current location
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title:
                  "${user['name']} (${user['role']})", // Display user's name as title
            ),
          ),
        );
      }
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(
            _currentUserPosition.latitude, _currentUserPosition.longitude),
        zoom: 20,
      );

      final GoogleMapController controller = await _controller.future;
      await controller
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    });
  }

  // Function to get user's current location
  Future<void> getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentUserPosition = LatLng(position.latitude, position.longitude);
        updateCurrentUserLocation(
            context, currentUserEmail, position.latitude, position.longitude);
        setState(() {});

        print(("Current location is $_currentUserPosition"));
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void addIUMarker() async {
    final Uint8List marketIcon =
        await getBytesFromAsset("assets/images/bar.png", 100);
    _marker.add(
      Marker(
        markerId: const MarkerId("uni"),
        position: uniLatLng,
        infoWindow: const InfoWindow(title: "Iqra University North Campus"),
        icon: BitmapDescriptor.fromBytes(marketIcon),
      ),
    );
  }

  // moveToCurrentUserLocation() {
  //   getUserCurrentLocation().then((value) async {
  //     // _marker.add(
  //     //   Marker(
  //     //       markerId: MarkerId("Student"),
  //     //       position: LatLng(
  //     //           _currentUserPosition.latitude, _currentUserPosition.longitude),
  //     //       infoWindow: const InfoWindow(title: "You Are Here")),
  //     // );

  //     // _marker.add(
  //     //   Marker(
  //     //     markerId: MarkerId(currentUserID),
  //     //     position: _currentUserPosition,
  //     //     infoWindow: InfoWindow(
  //     //       title: currentUserName,
  //     //     ),
  //     //     icon: BitmapDescriptor.defaultMarker,
  //     //   ),
  //     // );

  //     for (var user in onlineUsers) {
  //       _marker.add(
  //         Marker(
  //           markerId:
  //               MarkerId(user['email']), // Use the user's email as marker ID
  //           position: LatLng(user['currentLocationlat'],
  //               user['currentLocationlng']), // User's current location
  //           icon: BitmapDescriptor.defaultMarker,
  //           infoWindow: InfoWindow(
  //             title:
  //                 user['role'] - user['name'], // Display user's name as title
  //           ),
  //         ),
  //       );
  //     }
  //     CameraPosition cameraPosition = CameraPosition(
  //       target: LatLng(
  //           _currentUserPosition.latitude, _currentUserPosition.longitude),
  //       zoom: 20,
  //     );

  //     final GoogleMapController controller = await _controller.future;
  //     controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  //     setState(() {});
  //   });
  // }

  void getRightSideDriver() {
    LatLng currentPosition = _currentUserPosition!;
    double offset = 1.0; // 1 meter

    LatLng rightPosition =
        calculateRightPosition(_currentUserPosition!, offset);

    debugPrint("Original position: $currentPosition");
    debugPrint("Position 1 meter to the right: $rightPosition");
  }

  LatLng calculateRightPosition(
      LatLng currentUserPosition, double offsetInMeters) {
    final latitude = currentUserPosition.latitude;
    final longitude = currentUserPosition.longitude;

    // Convert offset to degrees based on Earth's radius and cosine of latitude
    final offsetInDegrees =
        offsetInMeters / (111132.0 * cos(latitude * pi / 180));

    // Add the offset to the longitude
    final newLongitude = longitude + offsetInDegrees;

    return LatLng(latitude, newLongitude);
  }

  List<LatLng> getRandomDriverLocations(LatLng currentUserPosition) {
    final List<LatLng> driverLocations = [];
    final double offsetInMeters = 1.0;
    LatLng currentPosition = _currentUserPosition!;
    double offset = 15.0; // 1 meter

    LatLng rightPosition = calculateRightPosition(currentPosition, offset);

    print("Original position: $currentPosition");
    print("Position 1 meter to the right: $rightPosition");

    // driverLocations.add(LatLng(currentUserPosition.latitude,
    //     currentUserPosition.longitude + offsetInMeters)); // Driver to the right
    // driverLocations.add(LatLng(currentUserPosition.latitude,
    //     currentUserPosition.longitude - offsetInMeters)); // Driver to the left
    driverLocations.add(rightPosition);

    return driverLocations;
  }

  Future<void> getRandomDriver() async {
    // Call the function after obtaining the user's current location
    List<LatLng> driverLocations =
        getRandomDriverLocations(_currentUserPosition!);
    final Uint8List markerIcon =
        await getBytesFromAsset("assets/images/school-bus.png", 100);
// Use the driverLocations list to add markers on the map (example)
    _marker.addAll(driverLocations.map((location) => Marker(
          markerId: MarkerId("driver-${driverLocations.indexOf(location)}"),
          position: location,
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(title: currentUserName),
        )));

    setState(() {});
  }

  loadDriversData() async {
    String? email = supabase.auth.currentUser?.email;
    if (email != null) {
      currentUserEmail = supabase.auth.currentUser!.email!;
    }
    await getUserCurrentLocation();
    await moveToCurrentUserLocation();
    // getRandomDriver();

    getRightSideDriver();
    _marker.addAll(_list);
    addIUMarker();
  }

  // working for routes
// blue line
  Future<List<LatLng>> getPolylinePointsforBlue() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      gplacesAPIKey,
      PointLatLng(uniLatLng.latitude, uniLatLng.longitude),
      PointLatLng(nazimabadchowrangi.latitude, nazimabadchowrangi.longitude),
      travelMode: TravelMode.driving,
      wayPoints: [
        PolylineWayPoint(
            location: "${upmoreLatLng.latitude},${upmoreLatLng.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${naganChowrangi.latitude},${naganChowrangi.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${sakhiHassan.latitude},${sakhiHassan.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${twokbustop.latitude},${twokbustop.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location:
                "${fiveStarChowrangi.latitude},${fiveStarChowrangi.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${hyderi.latitude},${hyderi.longitude}", stopOver: true),
        PolylineWayPoint(
            location: "${kda.latitude},${kda.longitude}", stopOver: true),
        PolylineWayPoint(
            location: "${dilpasand.latitude},${dilpasand.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${nazimabadnovii.latitude},${nazimabadnovii.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${baqaihospital.latitude},${baqaihospital.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location:
                "${nazimabadpetrolpump.latitude},${nazimabadpetrolpump.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${inquiryoffice.latitude},${inquiryoffice.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location:
                "${nazimabadchowrangi.latitude},${nazimabadchowrangi.longitude}",
            stopOver: true),
      ],
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  Future<List<LatLng>> getPolylinePointsforGreen() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      gplacesAPIKey,
      PointLatLng(uniLatLng.latitude, uniLatLng.longitude),
      PointLatLng(karimabad.latitude, karimabad.longitude),
      travelMode: TravelMode.driving,
      wayPoints: [
        PolylineWayPoint(
            location: "${upmoreLatLng.latitude},${upmoreLatLng.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${naganChowrangi.latitude},${naganChowrangi.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${bufferzone.latitude},${bufferzone.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${powerstation.latitude},${powerstation.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${sohrabgoth.latitude},${sohrabgoth.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${ancholi.latitude},${ancholi.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${waterpump.latitude},${waterpump.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${naseerabad.latitude},${naseerabad.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${ayeshamanzil.latitude},${ayeshamanzil.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${banapalace.latitude},${banapalace.longitude}",
            stopOver: true),
      ],
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  Future<List<LatLng>> getPolylinePointsforRed() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      gplacesAPIKey,
      PointLatLng(uniLatLng.latitude, uniLatLng.longitude),
      PointLatLng(hassansquare.latitude, hassansquare.longitude),
      travelMode: TravelMode.driving,
      wayPoints: [
        PolylineWayPoint(
            location: "${upmoreLatLng.latitude},${upmoreLatLng.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${naganChowrangi.latitude},${naganChowrangi.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${bufferzone.latitude},${bufferzone.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${powerstation.latitude},${powerstation.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${sohrabgoth.latitude},${sohrabgoth.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${saghircenter.latitude},${saghircenter.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location:
                "${gulshanchowrangi.latitude},${gulshanchowrangi.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location: "${nipa.latitude},${nipa.longitude}", stopOver: true),
        PolylineWayPoint(
            location:
                "${federalurduuniversity.latitude},${federalurduuniversity.longitude}",
            stopOver: true),
        PolylineWayPoint(
            location:
                "${baitulmukarammasjid.latitude},${baitulmukarammasjid.longitude}",
            stopOver: true),
      ],
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  generatePolylinesforDriver() {
    var selectedRoute = widget.driverRoute;
    if (selectedRoute == 'redline') {
      generatePolylineForRedLine();
      updateStopsforRedLine();
    } else if (selectedRoute == 'greenline') {
      generatePolylineForGreenLine();
      updateStopsforGreenLine();
    } else {
      generatePolylineForBlueLine();
      updateStopsforBlueLine();
    }
  }

  // Method to generate polyline for redline
  void generatePolylineForRedLine() async {
    List<LatLng> polylineCoordinates = await getPolylinePointsforRed();
    PolylineId id = PolylineId("redline");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  // Method to generate polyline for greenline
  void generatePolylineForGreenLine() async {
    List<LatLng> polylineCoordinates = await getPolylinePointsforGreen();
    PolylineId id = PolylineId("greenline");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  // Method to generate polyline for greenline
  void generatePolylineForBlueLine() async {
    List<LatLng> polylineCoordinates = await getPolylinePointsforBlue();
    PolylineId id = const PolylineId("blueline");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  updateStopsforRedLine() {
    for (var i = 0; i < redRouteLatLng.length; i++) {
      _marker.add(
        Marker(
            markerId: MarkerId(
              redRoute[i],
            ),
            position: redRouteLatLng[i],
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: stopsList[i],
            )),
      );
    }
  }

  updateStopsforGreenLine() {
    for (var i = 0; i < greenRouteLatLng.length; i++) {
      _marker.add(
        Marker(
            markerId: MarkerId(
              greenRoute[i],
            ),
            position: greenRouteLatLng[i],
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: stopsList[i],
            )),
      );
    }
  }

  updateStopsforBlueLine() {
    for (var i = 0; i < blueRouteLatLng.length; i++) {
      _marker.add(
        Marker(
            markerId: MarkerId(
              blueRoute[i],
            ),
            position: blueRouteLatLng[i],
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: stopsList[i],
            )),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    loadDriversData();
    generatePolylinesforDriver();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
          ), //from field
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Text("From : "),
                        Text(studentFromLoc),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          // to field
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Text("To : "),
                    Text(studentWhereToLoc),
                  ],
                )
              ],
            ),
          ),
          Container(
            height: MediaQuery.sizeOf(context).height * 0.1,
            width: MediaQuery.sizeOf(context).width * 1,
            color: Colors.green,
            child: GestureDetector(
              onTap: () {
                // manage your function to show seat booked.

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) =>
                //           const StudentWhereToLocationSearch()),
                // );
              },
              child: const Center(
                  child: Text(
                "Start Driving",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
