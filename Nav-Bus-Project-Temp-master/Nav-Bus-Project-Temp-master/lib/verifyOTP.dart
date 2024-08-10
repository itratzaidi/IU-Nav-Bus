import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iu_nav_bus/beg.dart';
import 'package:iu_nav_bus/driver.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String email;
  final bool isDriver;
  const VerifyOTPScreen(
      {super.key, required this.email, required this.isDriver});

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _OTP = TextEditingController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          // Add this Text widget
          const Text(
            "Enter OTP Code",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _OTP,
            decoration: const InputDecoration(
              hintText: 'Enter OTP',
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              veriyOTP(_OTP.text, widget.email);
            },
            child: const Text("Verify"),
          ),
          
          const SizedBox(
            height: 20,
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
                child: Image.network(ad3),
              ),
            ),
          ),
        ],
      )),
    );
  }

  veriyOTP(token, email) async {
    try {
      final res = await supabase.auth
          .verifyOTP(
        email: email,
        token: token,
        type: OtpType.magiclink,
      )
          .then((value) {
        log(value.user!.toString());
        currentUserID = value.user!.userMetadata!['sub'];
        currentUserEmail = value.user!.userMetadata!['email'];
        setState(() {
          debugPrint("Current User ID is $currentUserID");
          debugPrint("Current user email ID is $currentUserEmail");
        });

        updateUID(context, currentUserID, email);
        updateUserStatusOnFireStore(
          context,
          "true",
          email!,
        );

        if (widget.isDriver) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DrivePage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => begPage()),
          );
        }
      });
      if (res.error) {}
    } catch (e) {
      log("SomeThing Went Wrong");
      try {
        await supabase.auth
            .verifyOTP(
          email: email,
          token: token,
          type: OtpType.signup,
        )
            .then((value) {
          log(value.user!.toString());
          currentUserID = value.user!.userMetadata!['sub'];
          currentUserEmail = value.user!.userMetadata!['email'];
          setState(() {
            debugPrint("Current User ID is $currentUserID");
            debugPrint("Current user email ID is $currentUserEmail");
          });

          updateUID(context, currentUserID, email);
          updateUserStatusOnFireStore(
            context,
            "true",
            email!,
          );
          if (widget.isDriver) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DrivePage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => begPage()),
            );
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }
}


  // veriyOTPforDriver(token, email, name, licenseNumber, busNumber) async {
  //   try {
  //     final res = await supabase.auth
  //         .verifyOTP(
  //       email: email,
  //       token: token,
  //       type: OtpType.magiclink,
  //     )
  //         .then((value) async {
  //       log(value.user!.toString());
  //       currentUserID = value.user!.userMetadata!['sub'];
  //       currentUserEmail = value.user!.userMetadata!['email'];
  //       setState(() {
  //         debugPrint("Current User ID is $currentUserID");
  //         debugPrint("Current user email ID is $currentUserEmail");
  //       });

  //       await updateDriverProfile(
  //         context,
  //         currentUserID,
  //         name,
  //         email,
  //         busNumber,
  //         licenseNumber,
  //       );
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => begPage()),
  //       );
  //     });
  //   } catch (e) {
  //     log("SomeThing Went Wrong");
  //     try {
  //       await supabase.auth
  //           .verifyOTP(
  //         email: email,
  //         token: token,
  //         type: OtpType.signup,
  //       )
  //           .then((value) async {
  //         log(value.user!.toString());
  //         currentUserID = value.user!.userMetadata!['sub'];
  //         currentUserEmail = value.user!.userMetadata!['email'];
  //         setState(() {
  //           debugPrint("Current User ID is $currentUserID");
  //           debugPrint("Current user email ID is $currentUserEmail");
  //         });

  //         await updateDriverProfile(
  //           context,
  //           currentUserID,
  //           name,
  //           email,
  //           busNumber,
  //           licenseNumber,
  //         );
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => begPage()),
  //         );
  //       });
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             e.toString(),
  //           ),
  //         ),
  //       );
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           e.toString(),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // veriyOTPforStudent(token, email, name, registrationNumber) async {
  //   try {
  //     final res = await supabase.auth
  //         .verifyOTP(
  //       email: email,
  //       token: token,
  //       type: OtpType.magiclink,
  //     )
  //         .then((value) async {
  //       log(value.user!.toString());
  //       currentUserID = value.user!.userMetadata!['sub'];
  //       currentUserEmail = value.user!.userMetadata!['email'];
  //       setState(() {
  //         debugPrint("Current User ID is $currentUserID");
  //         debugPrint("Current user email ID is $currentUserEmail");
  //       });

  //       await updateStudentProfile(
  //         context,
  //         currentUserID,
  //         name,
  //         email,
  //         registrationNumber,
  //       );
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => begPage()),
  //       );
  //     });
  //   } catch (e) {
  //     log("SomeThing Went Wrong");
  //     try {
  //       await supabase.auth
  //           .verifyOTP(
  //         email: email,
  //         token: token,
  //         type: OtpType.signup,
  //       )
  //           .then((value) async {
  //         log(value.user!.toString());
  //         currentUserID = value.user!.userMetadata!['sub'];
  //         currentUserEmail = value.user!.userMetadata!['email'];
  //         setState(() {
  //           debugPrint("Current User ID is $currentUserID");
  //           debugPrint("Current user email ID is $currentUserEmail");
  //         });

  //         await updateStudentProfile(
  //           context,
  //           currentUserID,
  //           name,
  //           email,
  //           registrationNumber,
  //         );
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => begPage()),
  //         );
  //       });
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             e.toString(),
  //           ),
  //         ),
  //       );
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           e.toString(),
  //         ),
  //       ),
  //     );
  //   }
  // }

