// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import to handle calls

class EmergencySupportPage extends StatelessWidget {
  // Function to launch phone call
  void _launchCaller(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $number';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Support'),
        backgroundColor: Color.fromARGB(255, 72, 80, 155),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white, // Set the color of the back arrow to white
        ),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 72, 80, 155),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.local_hospital, color: Colors.red),
                title: Text('Medical Emergency'),
                subtitle: Text('Call for medical assistance'),
                trailing: IconButton(
                  icon: Icon(Icons.call, color: Colors.green),
                  onPressed: () => _launchCaller('1020'), // Example number
                ),
              ),
              ListTile(
                leading: Icon(Icons.local_police, color: Colors.blue),
                title: Text('Police'),
                subtitle:
                    Text('Call the police for any crime or safety issues'),
                trailing: IconButton(
                  icon: Icon(Icons.call, color: Colors.green),
                  onPressed: () => _launchCaller('15'), // Example number
                ),
              ),
              ListTile(
                leading: Icon(Icons.fire_truck, color: Colors.orange),
                title: Text('Fire Department'),
                subtitle: Text('Call in case of fire'),
                trailing: IconButton(
                  icon: Icon(Icons.call, color: Colors.green),
                  onPressed: () => _launchCaller('16'), // Example number
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Travel Safety Tips',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 72, 80, 155),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.info, color: Colors.teal),
                title: Text('Keep your valuables safe'),
                subtitle: Text(
                    'Always keep your valuables like passport, wallet, and electronics secure and out of sight.'),
              ),
              ListTile(
                leading: Icon(Icons.place, color: Colors.teal),
                title: Text('Be aware of your surroundings'),
                subtitle: Text(
                    'Stay alert and be aware of your surroundings, especially in crowded places.'),
              ),
              ListTile(
                leading: Icon(Icons.local_taxi, color: Colors.teal),
                title: Text('Use reputable transportation'),
                subtitle: Text(
                    'Use only reputable transportation services and avoid unmarked taxis.'),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => _launchCaller('911'), // Example number
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Call Emergency Services',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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