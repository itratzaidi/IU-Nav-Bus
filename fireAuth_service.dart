import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iu_nav_bus/global.dart';

class FirebaseFireStore {
  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

updateUserProfile(
    BuildContext context, String userid, String name, String email) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection("users");
  users.doc(userid).set({
    'uid': userid,
    'name': name,
    'email': email,
  }).then((value) {
    debugPrint("User Added");
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const LoginPage(),
    //   ),
    // );
  }).catchError((error) => debugPrint("Failed to add user: $error"));
}

updateDriverProfile(BuildContext context, String userid, String name,
    String email, String busNumber, String licenseNumber) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection("users");
  users.doc(email).set({
    'uid': userid,
    'name': name,
    'email': email,
    'role': "driver",
    'busNumber': busNumber,
    'licenseNumber': licenseNumber,
    'currentLocationlat': "",
    'currentLocationlng': "",
    'driverRoute': '',
  }).then((value) {
    debugPrint("driver Added");
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const LoginPage(),
    //   ),
    // );
  }).catchError((error) => debugPrint("Failed to add user: $error"));
}

updateStudentProfile(BuildContext context, String userid, String name,
    String email, String registrationNumber) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection("users");
  users.doc(email).set({
    'uid': userid,
    'name': name,
    'email': email,
    'role': "student",
    'currentLocationlat': "",
    'currentLocationlng': "",
    'registrationNumber': registrationNumber,
  }).then((value) {
    debugPrint("student Added");
  }).catchError((error) => debugPrint("Failed to add user: $error"));
}

Future<List<Map<String, dynamic>>> fetchOnlineDrivers() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('isOnline', isEqualTo: 'true')
        .where('role', isEqualTo: 'driver')
        .get();

    // Extract relevant fields from each document and store in a list of maps
    List<Map<String, dynamic>> onlineDriversList = snapshot.docs.map((doc) {
      return {
        'name': doc['name'],
        'email': doc.id,
        'role': doc['role'],
        'currentLocationlat': doc['currentLocationlat'],
        'currentLocationlng': doc['currentLocationlng'],
      };
    }).toList();
    log(onlineDriversList.toString());
    onlineDrivers = onlineDriversList;
    debugPrint("Total Online Drivers are ${onlineDriversList.length}");
    return onlineDriversList;
  } catch (e) {
    print("Error fetching online drivers: $e");

    return []; // Return empty list in case of error
  }
}

// updateUID(
//   BuildContext context,
//   String userid,
//   String email,
// ) {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   CollectionReference users = firestore.collection("users");
//   users.doc(email).set({
//     'uid': userid,
//   }).then((value) {
//     debugPrint("UID Updated");
//   }).catchError((error) => debugPrint("Failed to add user: $error"));
// }

Future<void> updateUID(BuildContext context, String uid, String email) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(email).update({
      'uid': uid,
    });
    debugPrint("UID updated successfully");
  } catch (e) {
    debugPrint("Error updating UID: $e");
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error updating UID"),
      ),
    );
  }
}

Future<void> updateDriverRoute(
    BuildContext context, String route, String email) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(email).update({
      'route': route,
    });
    debugPrint("route updated successfully");
  } catch (e) {
    debugPrint("Error updating route: $e");
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error updating UID"),
      ),
    );
  }
}

Future<void> updateUserStatusOnFireStore(
    BuildContext context, String status, String email) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(email).update({
      'isOnline': status,
    });
    debugPrint("status updated successfully");
  } catch (e) {
    debugPrint("Error updating status: $e");
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error updating status"),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> fetchOnlineUsers() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('isOnline', isEqualTo: 'true')
        .get();

    // Extract relevant fields from each document and store in a list of maps
    List<Map<String, dynamic>> onlineUsersList = snapshot.docs.map((doc) {
      return {
        'name': doc['name'],
        'email': doc.id,
        'role': doc['role'],
        'currentLocationlat': doc['currentLocationlat'],
        'currentLocationlng': doc['currentLocationlng'],
      };
    }).toList();
    log(onlineUsersList.toString());
    onlineUsers = onlineUsersList;
    debugPrint("Total Online Users are  ${onlineUsersList.length}");
    return onlineUsersList;
  } catch (e) {
    print("Error fetching online users: $e");

    return []; // Return empty list in case of error
  }
}

Future<void> updateCurrentUserLocation(
    BuildContext context, String email, double lat, double lng) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(email).update({
      'currentLocationlat': lat,
      'currentLocationlng': lng,
    });
    debugPrint("Current user location Updated updated successfully");
  } catch (e) {
    debugPrint("Error updating location: $e");
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error updating UID"),
      ),
    );
  }
}

Future<String?> checkUserRoleByEmail(String email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection("users");

  try {
    DocumentSnapshot snapshot = await users.doc(email).get();

    if (snapshot.exists) {
      // Document exists, retrieve the role
      return snapshot.get('role');
    } else {
      // Document does not exist
      return null;
    }
  } catch (error) {
    // Handle error
    debugPrint("Error checking user role: $error");
    return null;
  }
}

Future<String?> checkDriverRouteByEmail(String email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection("users");

  try {
    DocumentSnapshot snapshot = await users.doc(email).get();

    if (snapshot.exists) {
      // Document exists, retrieve the role
      return snapshot.get('route');
    } else {
      // Document does not exist
      return null;
    }
  } catch (error) {
    // Handle error
    debugPrint("Error checking user role: $error");
    return null;
  }
}

Future<String?> checkUserNameByEmail(String email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = firestore.collection("users");

  try {
    DocumentSnapshot snapshot = await users.doc(email).get();

    if (snapshot.exists) {
      // Document exists, retrieve the role
      return snapshot.get('name');
    } else {
      // Document does not exist
      return null;
    }
  } catch (error) {
    // Handle error
    debugPrint("Error checking user role: $error");
    return null;
  }
}
