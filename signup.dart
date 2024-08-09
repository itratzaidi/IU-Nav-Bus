// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/main.dart';
import 'package:iu_nav_bus/verifyOTP.dart';
import 'login.dart'; // Import the LoginPage

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isDriver =
      false; // Variable to track if signing up as a driver or student

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _registrationNumber = TextEditingController();
  final TextEditingController _busNumber = TextEditingController();
  final TextEditingController _licenseNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            color: Color.fromARGB(255, 72, 80, 155),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: const Color.fromARGB(255, 255, 253, 253),
                  iconSize: 30.0,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/bar.png'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'As a', // Heading
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Student',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Radio<bool>(
                        value: false, // False means Student
                        groupValue: _isDriver,
                        onChanged: (value) {
                          setState(() {
                            _isDriver = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Driver',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Radio<bool>(
                        value: true, // True means Driver
                        groupValue: _isDriver,
                        onChanged: (value) {
                          setState(() {
                            _isDriver = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
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
              const SizedBox(height: 20.0),
              SignUpFormField(
                controller: _name,
                label: 'Name',
                hintText: 'Please enter your name',
              ),
              const SizedBox(height: 20.0),
              SignUpFormField(
                controller: _email,
                label: 'Email',
                hintText: 'Please enter your email',
              ),
              const SizedBox(height: 20.0),
              if (_isDriver)
                Column(
                  children: [
                    SignUpFormField(
                      label: 'Bus Number',
                      hintText: 'Please enter your bus number',
                      controller: _busNumber,
                    ),
                    const SizedBox(height: 20.0),
                    SignUpFormField(
                      controller: _licenseNumber,
                      label: 'License Number',
                      hintText: 'Please enter your license number',
                    ),
                  ],
                )
              else
                SignUpFormField(
                  label: 'Registration Number',
                  hintText: 'Please enter your registration number',
                  controller: _registrationNumber,
                ),

              const SizedBox(height: 20.0),

              const SizedBox(height: 20.0),
              SizedBox(
                height: 40.0, // Set height of the button
                child: OutlinedButton(
                  onPressed: () async {
                    // Handle button press
                    // Check if user is already registered
                    DocumentSnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(_email.text)
                        .get();

                    if (snapshot.exists) {
                      String? role = snapshot['role'];
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Account already exists, Please login.")));
                      // isdriver = (role == 'driver');
                    } else {
                      if (_isDriver) {
                        await updateDriverProfile(
                          context,
                          "waiting for OTP Verification",
                          _name.text,
                          _email.text,
                          _busNumber.text,
                          _licenseNumber.text,
                        );
                        currentUserName = _name.text;
                        setState(() {});

                        await signInWithEmailOTP(
                          context,
                          _email.text,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VerifyOTPScreen(
                                    isDriver: true,
                                    email: _email.text,
                                  )),
                        );
                      } else {
                        if (_email.text.contains("@iqra.edu.pk")) {
                          await updateStudentProfile(
                            context,
                            "waiting for OTP verification",
                            _name.text,
                            _email.text,
                            _registrationNumber.text,
                          );

                          currentUserName = _name.text;
                          setState(() {});

                          await signInWithEmailOTP(
                            context,
                            _email.text,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerifyOTPScreen(
                                      isDriver: false,
                                      email: _email.text,
                                    )),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "For Students only emails with iqra.edu.pk is allowed."),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Colors.black), // Set border color to black
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Set border radius
                    ),
                  ),
                  child: const Text(
                    'CREATE AN ACCOUNT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Make text bold
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle "Log In" button press

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => loginPage()),
                      );
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: MediaQuery.of(context)
                      .viewInsets
                      .bottom), // Adjust spacing for keyboard
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;

  const SignUpFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label, // Name heading
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // Set the background color
            borderRadius: BorderRadius.circular(20.0), // Set border radius
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(15.0),
              hintText: hintText, // Show hint text when input is not focused
              border: InputBorder.none, // Remove the default border
            ),
          ),
        ),
      ],
    );
  }
}

class CircleCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const CircleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black, // Set border color to black
        ),
      ),
      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: Colors.transparent, // Hide default check color
        ),
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
