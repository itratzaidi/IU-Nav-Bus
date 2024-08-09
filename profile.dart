import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase package
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // Remove the debug banner
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _editedName = '';
  String _editedEmail = '';
  String _editedPhone = '';

  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 72, 80, 155),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Profile'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'Edit Profile') {
                  _isEditing = true;
                } else if (value == 'Save') {
                  _isEditing = false;
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                'Edit Profile',
                'Save',
              ].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                margin: EdgeInsets.all(20.0),
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff23e1d4),
                      Color(0xff7499c8),
                      Color(0xff74accd),
                    ],
                    stops: [0, 0.5, 1],
                    begin: Alignment(-0.0, -1.0),
                    end: Alignment(-0.0, 0.9),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    _buildHeading('Personal Information'),
                    _buildInfoBox(
                      leadingIcon: Icons.person,
                      title: 'Name',
                      value: _editedName,
                      onChanged: (value) {
                        setState(() {
                          _editedName = value;
                        });
                      },
                    ),
                    _buildInfoBox(
                      leadingIcon: Icons.email,
                      title: 'Email',
                      value: _editedEmail,
                      onChanged: (value) {
                        setState(() {
                          _editedEmail = value;
                        });
                      },
                    ),
                    _buildInfoBox(
                      leadingIcon: Icons.phone,
                      title: 'Phone Number',
                      value: _editedPhone,
                      onChanged: (value) {
                        setState(() {
                          _editedPhone = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await signOut(context);
                      },
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData leadingIcon,
    required String title,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, size: 30, color: Colors.blue),
          SizedBox(width: 20),
          Expanded(
            child: TextFormField(
              initialValue: value,
              enabled: _isEditing,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: title,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> signOut(BuildContext context) async {
  final supabase = Supabase.instance.client;
  String? email = supabase.auth.currentUser?.email;
  if (email != null) {
    await updateUserStatusOnFireStore(context, "false", email);
  }
  await supabase.auth.signOut();
  Navigator.pushReplacementNamed(
      context, '/login'); // Adjust route name as needed
}

Future<void> updateUserStatusOnFireStore(
    BuildContext context, String status, String email) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final usersCollection =
        firestore.collection('users'); // Adjust the collection path as needed

    final querySnapshot =
        await usersCollection.where('email', isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await usersCollection.doc(docId).update({'status': status});
    }
  } catch (e) {
    // Handle errors (e.g., show an error message)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Failed to update user status: $e'),
    ));
  }
}
