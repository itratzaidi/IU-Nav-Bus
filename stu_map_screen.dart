import 'dart:async';
import 'dart:developer' as log;
import 'dart:math' hide log;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iu_nav_bus/config.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/select_whereto_loc.dart';
import 'package:dio/dio.dart';

class StudentMapScreen extends StatefulWidget {
  final LatLng fromlatlng;
  final LatLng tolatlng;
  final LatLng userLatLngformarker;
  final bool fromUniToHome;
  final LatLng needDriverLatLng;

  const StudentMapScreen(
      {super.key,
      required this.fromlatlng,
      required this.tolatlng,
      required this.userLatLngformarker,
      required this.fromUniToHome,
      required this.needDriverLatLng});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Uint8List? busIcon;
  Uint8List? userIcon;
  final Dio _dio = Dio();

  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(37.4, -122), zoom: 14);

  List<Marker> _marker = [];
  final List<Marker> _list = [];

  // function to calculate distance

  Future<Map<String, dynamic>> getDistanceMatrix(double slatitude,
      double slongitude, double dlatitude, double dlongitude) async {
    final Dio _dio = Dio();

    try {
      final Response response = await _dio.get(
        "https://maps.googleapis.com/maps/api/distancematrix/json",
        queryParameters: {
          'origins': '$slatitude,$slongitude',
          'destinations': '$dlatitude,$dlongitude',
          'key': gplacesAPIKey,
        },
      );

      // Handle the response data
      if (response.statusCode == 200) {
        var data = response.data;
        var elements = data['rows'][0]['elements'][0];
        var distance = elements['distance']['text'];
        var duration = elements['duration']['text'];
        print('Distance: $distance');
        print('Duration: $duration');
        setState(() {
          selectedDriverDistance = distance;
          selectedDriverArrivalTime = duration;
        });
        // log.log(response.data.toString());
        return response.data;
      } else {
        throw Exception('Failed to fetch distance matrix data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch distance matrix data');
    }
  }

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

  moveToCurrentUserLocation() async {
    // getUserCurrentLocation().then((value) async {
    //   // _marker.add(
    //   //   Marker(
    //   //       markerId: MarkerId("Student"),
    //   //       position: LatLng(
    //   //           _currentUserPosition.latitude, _currentUserPosition.longitude),
    //   //       infoWindow: const InfoWindow(title: "You Are Here")),
    //   // );
    // });

    CameraPosition cameraPosition = CameraPosition(
      target:
          LatLng(_currentUserPosition.latitude, _currentUserPosition.longitude),
      zoom: 20,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    debugPrint("Animate to$_currentUserPosition");
    setState(() {});
  }

  void getRightSideDriver() {
    LatLng currentPosition = widget.needDriverLatLng;
    double offset = 1.0; // 1 meter

    LatLng rightPosition =
        calculateRightPosition(widget.needDriverLatLng, offset);

    print("Original position: $currentPosition");
    print("Position 1 meter to the right: $rightPosition");
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
    final double offsetInMeters = 2.0;
    LatLng currentPosition = widget.needDriverLatLng;
    double offset = 15.0; // 1 meter

    LatLng rightPosition = calculateRightPosition(currentPosition, offset);

    print("Original position: $currentPosition");
    print("Position 1 meter to the right: $rightPosition");

    // driverLocations.add(LatLng(currentUserPosition.latitude,
    //     currentUserPosition.longitude + offsetInMeters)); // Driver to the right
    // driverLocations.add(LatLng(currentUserPosition.latitude,
    //     currentUserPosition.longitude - offsetInMeters)); // Driver to the left
    driverLocations.add(rightPosition);
    randomDriverLocation = driverLocations.first;
    debugPrint("Random Driver location is $randomDriverLocation");
    return driverLocations;
  }

  double generateRandomOffset(double radiusInMeters) {
    final random = Random();
    final sign = random.nextBool() ? 1.0 : -1.0;
    final offset = random.nextDouble() * radiusInMeters * sign;
    return offset / 111132.0; // Convert meters to degrees (approximately)
  }

  Future<void> getRandomDriver() async {
    // Call the function after obtaining the user's current location
    List<LatLng> driverLocations =
        getRandomDriverLocations(_currentUserPosition);
    final Uint8List markerIcon =
        await getBytesFromAsset("assets/images/school-bus.png", 100);
    // Use the driverLocations list to add markers on the map (example)
    _marker.addAll(driverLocations.map((location) => Marker(
          markerId: MarkerId("driver-${driverLocations.indexOf(location)}"),
          position: location,
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: const InfoWindow(title: "Your IU Driver"),
        )));
    // getPolylinePointsforStudenttoBus().then(
    //     (coordinates) => {generatePolyLineFromPointsforStudent(coordinates)});
    setState(() {});
  }

  // working for routes
// blue line
  Map<PolylineId, Polyline> polylines = {};
  Future<List<LatLng>> getPolylinePoints() async {
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

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("blueline");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  // green line

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

  void generatePolyLineFromPointsforGreen(
      List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("greenline");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.green,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  // red line

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

  void generatePolyLineFromPointsforRed(
      List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("redline");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    updateUserStatus(context, "true");
    fetchOnlineUsers();
    _marker.addAll(_list);
    addIUMarker();
    loadData();
    // addfromTomarker();
    getPolylinePoints().then((coordinates) => {
          generatePolyLineFromPoints(coordinates),
        });
    getPolylinePointsforGreen().then(
        (coordinates) => {generatePolyLineFromPointsforGreen(coordinates)});
    getPolylinePointsforRed()
        .then((coordinates) => {generatePolyLineFromPointsforRed(coordinates)});
  }

  void addIUMarker() async {
    final Uint8List marketIcon =
        await getBytesFromAsset("assets/images/bar.png", 100);
    _marker.add(
      Marker(
        markerId: const MarkerId("uni"),
        position: uniLatLng,
        infoWindow: InfoWindow(title: "IU"),
        icon: BitmapDescriptor.fromBytes(marketIcon),
      ),
    );
  }

  addfromTomarker() {
    _marker.add(
      Marker(
        markerId: MarkerId(widget.fromUniToHome ? "to" : "from"),
        position: widget.userLatLngformarker,
        infoWindow: InfoWindow(title: widget.fromUniToHome ? "to" : "from"),
      ),
    );
  }

  Future<void> loadData() async {
    await getUserCurrentLocation();
    await moveToCurrentUserLocation();
    // await getRandomDriver();
    for (var i = 0; i < stops.length; i++) {
      _marker.add(
        Marker(
            markerId: MarkerId(
              stopsList[i],
            ),
            position: stops[i],
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: stopsList[i],
            )),
      );
    }
    final Uint8List markerIcon =
        await getBytesFromAsset("assets/images/student.png", 100);
    for (var user in onlineUsers) {
      debugPrint(onlineUsers.length.toString());
      debugPrint("Updating User marker $user");
      if (user['currentLocationlat'] != "" &&
          user['currentLocationlng'] != "") {
        _marker.add(
          Marker(
            markerId:
                MarkerId(user['email']), // Use the user's email as marker ID
            position:
                LatLng(user['currentLocationlat'], user['currentLocationlng']),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow(
              title:
                  "${user['name']} (${user['role']})", // Display user's name as title
            ),
          ),
        );
      }
    }
  }

// get route from student to bus
  Future<List<LatLng>> getPolylinePointsforStudenttoBus() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      gplacesAPIKey,
      PointLatLng(
          _currentUserPosition.latitude, _currentUserPosition.longitude),
      PointLatLng(selectedDriverLat, selectedDriverLng),
      travelMode: TravelMode.driving,
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

  void generatePolyLineFromPointsforStudent(
      List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("studentToBus");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  // Variable to hold user's current position
  late LatLng _currentUserPosition; //= LatLng(32, 32);

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
            child: Text(
              "There are ${onlineDrivers.length} Drivers are available.",
              style: const TextStyle(fontSize: 19),
            ),
          ),
          Container(
            height: MediaQuery.sizeOf(context).height * 0.2,
            width: MediaQuery.sizeOf(context).width * 1,
            color: Colors.green,
            child: ListView.separated(
              itemCount: onlineDrivers.length,
              itemBuilder: (context, index) {
                final driver = onlineDrivers[index];
                return ListTile(
                  onTap: () async {
                    debugPrint(
                        'Lat: ${driver['currentLocationlat']}, Lng: ${driver['currentLocationlng']}');
                    getDistanceMatrix(
                      _currentUserPosition.latitude,
                      _currentUserPosition.longitude,
                      driver['currentLocationlat'],
                      driver['currentLocationlng'],
                    );
                    setState(() {
                      selectedDriverLat = driver['currentLocationlat'];
                      selectedDriverLng = driver['currentLocationlng'];
                      selectedDriverName = driver['name'];
                      getPolylinePointsforStudenttoBus().then((coordinates) =>
                          {generatePolyLineFromPointsforStudent(coordinates)});
                    });

                    await Future.delayed(const Duration(seconds: 3));

                    showBasicNotification(
                      "Your Driver $selectedDriverName is on the Way",
                      "Your Driver is Arriving at $selectedDriverArrivalTime",
                    );

                    print(selectedDriverLat);
                    print(selectedDriverLng);
                    print(selectedDriverName);
                  },
                  title: Text(driver['name']),
                  // subtitle: Text(

                  //   // 'Lat: ${driver['currentLocationlat']}, Lng: ${driver['currentLocationlng']}',
                  // ),
                  trailing: Icon(Icons.directions_car),
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
          ),
        ],
      ),
    );
  }
}
