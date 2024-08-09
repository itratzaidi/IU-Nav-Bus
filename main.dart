// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iu_nav_bus/applifecycle.dart';
import 'package:iu_nav_bus/config.dart';
import 'package:iu_nav_bus/driver.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/fireStorage_Service.dart';
import 'package:iu_nav_bus/firebase_options.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/notification_service.dart';
import 'package:iu_nav_bus/student_decision_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'page2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotification();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(LifeCycleManager(
    key: GlobalKey(), // Provide a GlobalKey as the key
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IQRA Bus App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LifeCycleManager(
        // Wrap your home widget with LifeCycleManager
        key: GlobalKey(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  checkOnlineUsers() async {
    onlineUsers = await fetchOnlineUsers();
    setState(() {});
  }

  fetchAdsUrls() async {
    final FirestorageService firestorageService = FirestorageService();
    final urls = await firestorageService.fetchImagesFromAdsFolder();
    setState(() {
      log(adsUrls.toString());

      adsUrls = urls;
    });
  }

  updateAdsLinks() async {
    final FirestorageService firestorageService = FirestorageService();
    final ad1Url = await firestorageService.fetchImageUrlByFileName("ad1.jpeg");
    final ad2Url = await firestorageService.fetchImageUrlByFileName("ad2.jpeg");
    final ad3Url = await firestorageService.fetchImageUrlByFileName("ad3.jpeg");
    setState(() {
      if (ad1Url != null) {
        ad1 = ad1Url;
        debugPrint(ad1);
      }
      if (ad2Url != null) {
        ad2 = ad2Url;
        debugPrint(ad2);
      }
      if (ad3Url != null) {
        ad3 = ad3Url;
        debugPrint(ad3);
      }
    });
  }

  @override
  void initState() {
    checkOnlineUsers();
    fetchOnlineDrivers();
    updateAdsLinks();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white, // Start color: white
              Color(0xFF0139A7), // End color: #0139A7
            ],
          ),
        ),
        child: ListView(
          children: [
            // temprary signout button for testing

            SizedBox(height: 100), // Add space above the image
            Transform.translate(
              offset: Offset(0, -50), // Adjust the position of the image
              child: Image.asset(
                'assets/images/logo.png',
                height: 250, // Resize the image height
                width: 250, // Resize the image width
              ),
            ),
            SizedBox(height: 20), // Add space between the images
            Image.asset(
              'assets/images/bus1.png', // New image path
              height: 120, // Resize the image height
              width: 400, // Resize the image width
            ),
            SizedBox(height: 20), // Add space below the bus image
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 50),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'IU NAVBUS ',
                  style: TextStyle(
                    fontSize: 40, // Increase text size
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color to white
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () async {
                  if (supabase.auth.currentUser != null) {
                    String? role = await checkUserRoleByEmail(
                        supabase.auth.currentUser!.email!);
                    if (role != null) {
                      if (role == 'driver') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DrivePage()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StudentDecision()));
                      }
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Page2()),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60.0),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'GET STARTED',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final supabase = Supabase.instance.client;

signInWithEmailOTP(BuildContext context, String email) async {
  try {
    await supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: kIsWeb ? null : 'io.supabase.flutter://signin-callback/',
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        e.toString(),
      ),
    ));
  }
}
