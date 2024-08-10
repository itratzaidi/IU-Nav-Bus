// ignore_for_file: use_super_parameters, await_only_futures, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:iu_nav_bus/driverroutes.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/main.dart';

class DrivePage extends StatefulWidget {
  const DrivePage({Key? key}) : super(key: key);

  @override
  State<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends State<DrivePage> {
  String selectedRoute = "redline";
  @override
  void initState() {
    loadDriverData();
    updateRoute();

    super.initState();
  }

  loadDriverData() async {
    String? email = await supabase.auth.currentUser?.email;

    if (email != null) {
      currentUserEmail = email;
      currentUserName = (await checkUserNameByEmail(email))!;
      setState(() {});
    }
  }

  updateRoute() async {
    await updateDriverRoute(
      context,
      selectedRoute,
      currentUserEmail,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver's Portal"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: Text("Hi $currentUserName !"),
            ),
            DropdownButton<String>(
              value: selectedRoute,
              onChanged: (String? newValue) {
                setState(() {
                  selectedRoute = newValue!;
                  updateRoute();
                  setState(() {});
                });
              },
              items: <String>['redline', 'blueline', 'greenline']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverRouteScreen(
                      driverRoute: selectedRoute,
                    ),
                  ),
                );
              },
              child: const Text("Select Route"),
            ),
            Expanded(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 1,
                child: Image.asset("assets/images/ad3.jpeg"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
