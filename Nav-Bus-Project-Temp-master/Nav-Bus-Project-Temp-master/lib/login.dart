import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/global.dart';
import 'package:iu_nav_bus/main.dart';
import 'package:iu_nav_bus/verifyOTP.dart';
import 'signup.dart'; // Import the SignUpPage
import 'forgot.dart'; // Import the ForgotPage
import 'beg.dart'; // Import the begPage

class loginPage extends StatefulWidget {
  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pasword = TextEditingController();
  bool isdriver = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
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
                  icon: Icon(Icons.arrow_back),
                  color: Color.fromARGB(255, 255, 254, 254),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Log In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                    child: Image.network(ad2),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              LoginFormField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _email,
              ),
              // SizedBox(height: 20.0),
              // LoginFormField(
              //   label: 'Password',
              //   hintText: 'Enter your password',
              //   controller: _pasword,
              // ),
              const SizedBox(height: 20.0),
              SizedBox(
                height: 40.0,
                child: ElevatedButton(
                  onPressed: () async {
                    // Check if user is already registered
                    DocumentSnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(_email.text)
                        .get();

                    if (snapshot.exists) {
                      String? role = snapshot['role'];
                      isdriver = (role == 'driver');

                      // Proceed with login
                      await signInWithEmailOTP(context, _email.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerifyOTPScreen(
                            email: _email.text,
                            isDriver: isdriver,
                          ),
                        ),
                      );
                    } else {
                      // Show Snackbar to prompt user to create an account
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'User not found. Please create an account first.'),
                        ),
                      );

                      // String? role = await checkUserRoleByEmail(_email.text);

                      // if (role == "driver") {
                      //   isdriver = true;
                      // }

                      // await signInWithEmailOTP(
                      //   context,
                      //   _email.text,
                      // );
                    }

                    // // Navigate to the begPage
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => begPage()),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text(
                    'LOG IN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  // Navigate to the ForgotPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPage()),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              SizedBox(
                height: 40.0,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the SignUpPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'CREATE AN ACCOUNT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;

  const LoginFormField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(15.0),
              hintText: hintText,
              border: InputBorder.none,
            ),
            controller: controller,
          ),
        ),
      ],
    );
  }
}
